/*===============================================
    AdminMemberController.java
    - 관리자 회원 관리 컨트롤러
    - 활동 회원 목록/상세, 탈퇴 회원 목록/상세
===============================================*/
package com.doit.app.controller;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.AdminMemberVo;
import com.doit.app.domain.AdminVo;
import com.doit.app.service.AdminMemberService;
import org.springframework.web.bind.annotation.RequestBody;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@Slf4j
@Controller
public class AdminMemberController
{
    private final AdminMemberService adminMemberService;


    private boolean isAdminLoggedIn(HttpSession session)
    {
        return session.getAttribute("loginAdmin") != null;
    }

    private Long adminNo(HttpSession session)
    {
        AdminVo admin = (AdminVo) session.getAttribute("loginAdmin");
        return admin.getAdminNo();
    }


    //  활동 회원 목록

    // GET /admin/members?page=1&keyword=
    @GetMapping("/admin/members")
    public String memberList(@RequestParam(name="page",    defaultValue = "1")  int    page,
                             @RequestParam(name="keyword", defaultValue = "")   String keyword,
                             HttpSession session, Model model)
    {
        if (!isAdminLoggedIn(session)) { return "redirect:/login"; }

        PaginateUtil pageInfo        = adminMemberService.createPageInfo(page);
        List<AdminMemberVo> members  = adminMemberService.getActiveMembers(page, keyword.trim(), pageInfo);

        model.addAttribute("members",  members);
        model.addAttribute("pageInfo", pageInfo);
        return "admin/members";
    }


    //  활동 회원 단건 (AJAX)

    // GET /admin/member/{memberNo} - 드로어 상세용
    @GetMapping("/admin/member/{memberNo}")
    @ResponseBody
    public ResponseEntity<AdminMemberVo> memberDetail(@PathVariable(name = "memberNo") Long memberNo,
                                                       HttpSession session)
    {
        if (!isAdminLoggedIn(session)) { return ResponseEntity.status(401).build(); }
        AdminMemberVo member = adminMemberService.getActiveMember(memberNo);
        if (member == null) { return ResponseEntity.notFound().build(); }
        return ResponseEntity.ok(member);
    }


    //  활동 회원 상세 페이지

    // GET /admin/members/{memberNo} - 상세 페이지
    @GetMapping("/admin/members/{memberNo}")
    public String memberDetailPage(@PathVariable(name = "memberNo") Long memberNo,
                                    HttpSession session, Model model)
    {
        if (!isAdminLoggedIn(session)) { return "redirect:/login"; }
        AdminMemberVo member = adminMemberService.getActiveMember(memberNo);
        if (member == null) { return "redirect:/admin/members"; }
        model.addAttribute("member", member);
        return "admin/memberDetail";
    }


    //  탈퇴 회원 목록

    // GET /admin/leaveMembers?page=1
    @GetMapping("/admin/leaveMembers")
    public String leaveMemberList(@RequestParam(name = "page", defaultValue = "1") int page
    								,HttpSession session
                                    , Model model){
    	
        if (!isAdminLoggedIn(session))
        { 
        	return "redirect:/login";
        }

        PaginateUtil pageInfo = adminMemberService.createPageInfo(page);
        List<AdminMemberVo> leaveMembers  = adminMemberService.getLeaveMembers(page, pageInfo);

        model.addAttribute("leaveMembers", leaveMembers);
        model.addAttribute("pageInfo",     pageInfo);
        return "admin/leaveMembers";
    }


    //  탈퇴 회원 단건 (AJAX)

    // GET /admin/leaveMember/{memberNo} - 드로어 상세용
    @GetMapping("/admin/leaveMember/{memberNo}")
    @ResponseBody
    public ResponseEntity<AdminMemberVo> leaveMemberDetail(@PathVariable(name = "memberNo") Long memberNo,
                                                            HttpSession session)
    {
        if (!isAdminLoggedIn(session)) { return ResponseEntity.status(401).build(); }
        AdminMemberVo member = adminMemberService.getLeaveMember(memberNo);
        if (member == null) { return ResponseEntity.notFound().build(); }
        return ResponseEntity.ok(member);
    }


    //  회원 제재

    // POST /admin/member/{memberNo}/sanction - 제재 등록 (AJAX)
    @PostMapping("/admin/member/{memberNo}/sanction")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> sanctionMember(
            @PathVariable(name = "memberNo") Long memberNo,
            @RequestBody Map<String, Object> body,
            HttpSession session)
    {
        if (!isAdminLoggedIn(session)) {
            return ResponseEntity.status(401).body(Map.of("result", "unauthorized"));
        }

        int    level   = Integer.parseInt(body.getOrDefault("level",   "1").toString());
        String reason  = (String) body.getOrDefault("reason",  "");
        String comment = (String) body.getOrDefault("comment", "");

        adminMemberService.sanctionMember(memberNo, level, reason, comment, adminNo(session));
        return ResponseEntity.ok(Map.of("result", "ok"));
    }
}
