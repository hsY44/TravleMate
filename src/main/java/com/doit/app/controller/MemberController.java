/*===============================================
    MemberController.java
    - 회원 관련 요청 처리 컨트롤러
    - 회원가입 / 로그인 / 로그아웃 / 마이페이지
===============================================*/
package com.doit.app.controller;

import com.doit.app.domain.AdminVo;
import com.doit.app.domain.MemberVo;
import com.doit.app.service.AdminService;
import com.doit.app.service.MemberService;
import com.doit.app.service.QnaService;
import com.doit.app.service.TravelService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RequiredArgsConstructor
@Slf4j
@Controller
public class MemberController
{
    private final MemberService memberService;
    private final AdminService  adminService;
    private final TravelService travelService;
    private final QnaService    qnaService;



    //  회원가입

    // 회원가입 폼 (GET /register)
    @GetMapping("/register")
    public String registerForm()
    {
        return "user/register";
    }

    // 아이디 중복확인 (GET /member/checkId) - AJAX
    // register.jsp의 checkId() 함수 → ?id=입력값
    @GetMapping("/member/checkId")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> checkId(@RequestParam(name="id") String id)
    {
        boolean available = memberService.isIdAvailable(id);
        return ResponseEntity.ok(Map.of("available", available));
    }

    // 닉네임 중복확인 (GET /member/checkNickname) - AJAX
    // register.jsp의 checkNickname() 함수 → ?nickname=입력값
    @GetMapping("/member/checkNickname")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> checkNickname(@RequestParam(name="nickname") String nickname)
    {
        boolean available = memberService.isNicknameAvailable(nickname);
        return ResponseEntity.ok(Map.of("available", available));
    }

    // 회원가입 처리 (POST /register) - AJAX
    // register.js의 submitRegister() 함수 → JSON body 수신
    // 성공 시 {"result": "ok"} 반환
    @PostMapping("/register")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> register(@RequestBody MemberVo memberVo)
    {
        memberService.register(memberVo);
        return ResponseEntity.ok(Map.of("result", "ok"));
    }


    //  로그인

    // 로그인 폼 (GET /login)
    // 이미 로그인된 경우 메인으로 이동
    @GetMapping("/login")
    public String loginForm(HttpSession session)
    {
        if (session.getAttribute("loginMember") != null) { return "redirect:/contents"; }
        if (session.getAttribute("loginAdmin")  != null) { return "redirect:/admin/members"; }
        return "user/login";
    }

    // 로그인 처리 (POST /login)
    // login.jsp 폼 파라미터: loginId, password, role(member|admin)
    @PostMapping("/login")
    public String login(@RequestParam(name="loginId") String loginId,
                        @RequestParam(name="password") String password,
                        @RequestParam(name="role", defaultValue = "member") String role,
                        HttpSession session,
                        Model model)
    {
        if ("admin".equals(role))
        {
            // 관리자 로그인
            AdminVo loginAdmin = adminService.login(loginId, password);

            if (loginAdmin == null)
            {
                model.addAttribute("errorMsg", "관리자 아이디 또는 비밀번호가 올바르지 않습니다.");
                return "user/login";
            }

            // 로그인 성공 → 관리자 세션 저장 후 관리자 페이지 이동
            session.setAttribute("loginAdmin", loginAdmin);
            return "redirect:/admin/members";
        }

        // 회원 로그인
        MemberVo loginMember = memberService.login(loginId, password);

        if (loginMember == null)
        {
            model.addAttribute("errorMsg", "아이디 또는 비밀번호가 올바르지 않습니다.");
            return "user/login";
        }

        // 제재(정지) 여부 확인 - 비밀번호 일치 후 별도 체크
        if (memberService.isSuspended(loginMember.getMemberNo()))
        {
            model.addAttribute("errorMsg", "계정이 정지된 상태입니다. 관리자에게 문의해주세요.");
            return "user/login";
        }

        // 로그인 성공 → 회원 세션 저장 후 콘텐츠 메인 이동
        // sidebar_user.jsp에서 ${sessionScope.nickname} 으로 닉네임 표시
        session.setAttribute("loginMember", loginMember);
        session.setAttribute("nickname",    loginMember.getNickname());
        session.setAttribute("memberId",    loginMember.getMemberNo()); // contentDetail.jsp 즐겨찾기/리뷰 조건 분기용
        return "redirect:/contents";
    }


    //  마이페이지

    // 마이페이지 (GET /mypage)
    // 세션에서 loginMember 꺼내 member + favorites 를 model 에 담아 뷰 반환
    @GetMapping("/mypage")
    public String mypageForm(HttpSession session, Model model)
    {
        MemberVo loginMember = (MemberVo) session.getAttribute("loginMember");
        if (loginMember == null) { return "redirect:/login"; }
        model.addAttribute("member",             loginMember);
        model.addAttribute("favorites",          memberService.getBookmarks(loginMember.getMemberNo()));
        model.addAttribute("reviews",            memberService.getReviews(loginMember.getMemberNo()));
        model.addAttribute("plans",              travelService.getPlansByMemberNo(loginMember.getMemberNo()));
        model.addAttribute("receivedInvitations", travelService.getReceivedInvitations(loginMember.getMemberNo()));
        model.addAttribute("inquiries",          qnaService.getRecentQnasByMemberNo(loginMember.getMemberNo()));
        model.addAttribute("inquiryCategories",  qnaService.getQnaTypes());
        return "user/mypage";
    }

    // 닉네임 중복확인 - 자기 자신 제외 (GET /member/checkNicknameUpdate) - AJAX
    // 세션에서 memberNo 를 가져오므로 클라이언트에서 memberNo 를 노출하지 않음
    @GetMapping("/member/checkNicknameUpdate")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> checkNicknameForUpdate(@RequestParam(name = "nickname") String nickname,
                                                                       HttpSession session)
    {
        MemberVo loginMember = (MemberVo) session.getAttribute("loginMember");
        if (loginMember == null)
        {
            return ResponseEntity.status(401).body(Map.of("available", false));
        }
        boolean available = memberService.isNicknameAvailableForUpdate(nickname, loginMember.getMemberNo());
        return ResponseEntity.ok(Map.of("available", available));
    }

    // 회원 정보 수정 (POST /member/update) - AJAX
    // 성공 시 세션의 loginMember 도 갱신 (닉네임 표시를 위해 nickname 세션도 갱신)
    @PostMapping("/member/update")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> updateMember(@RequestBody MemberVo memberVo,
                                                             HttpSession session)
    {
        MemberVo loginMember = (MemberVo) session.getAttribute("loginMember");
        if (loginMember == null)
        {
            return ResponseEntity.status(401).body(Map.of("result", "unauthorized"));
        }

        // memberNo 는 세션에서 가져와 덮어씀 (클라이언트 조작 방지)
        memberVo.setMemberNo(loginMember.getMemberNo());
        memberService.updateMember(memberVo);

        // 세션 정보 갱신
        loginMember.setName(memberVo.getName());
        loginMember.setNickname(memberVo.getNickname());
        loginMember.setEmail(memberVo.getEmail());
        loginMember.setPhoneNo(memberVo.getPhoneNo());
        session.setAttribute("nickname", loginMember.getNickname());

        return ResponseEntity.ok(Map.of("result", "ok"));
    }


    // 회원 탈퇴 (POST /member/withdraw) - AJAX
    // 1) 비밀번호 검증 (재로그인과 동일 방식)
    // 2) 호스트 계획 처리 - 활성 게스트에게 위임, 게스트 없으면 계획 삭제
    // 3) MEMBER_ACTIVE → MEMBER_LEAVE 이동 (트랜잭션)
    // 4) 세션 무효화 후 {"result": "ok"} 반환 → JS 에서 /login 으로 이동
    @PostMapping("/member/withdraw")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> withdraw(@RequestBody Map<String, String> body,
                                                         HttpSession session)
    {
        MemberVo loginMember = (MemberVo) session.getAttribute("loginMember");
        if (loginMember == null)
        {
            return ResponseEntity.status(401).body(Map.of("result", "unauthorized"));
        }

        // 비밀번호 검증 - loginId + pw 로 DB 조회 (null 이면 불일치)
        String pw = body.get("pw");
        if (memberService.login(loginMember.getLoginId(), pw) == null)
        {
            return ResponseEntity.ok(Map.of("result", "fail", "msg", "비밀번호가 올바르지 않습니다."));
        }

        // 호스트 계획 처리 - 탈퇴 전 필수 (위임 또는 삭제)
        travelService.handleWithdrawal(loginMember.getMemberNo());

        memberService.withdraw(loginMember.getMemberNo());
        session.invalidate();
        return ResponseEntity.ok(Map.of("result", "ok"));
    }


    //  로그아웃

    // 로그아웃 (GET /logout)
    // 세션 전체 무효화 (loginMember, loginAdmin, nickname 모두 제거)
    @GetMapping("/logout")
    public String logout(HttpSession session)
    {
        session.invalidate();
        return "redirect:/login";
    }
}
