/*===============================================
    QnaController.java
    - 문의 관련 요청 처리 컨트롤러
    - 문의 폼 / 문의 등록 / 문의 내역 / 문의 상세
===============================================*/
package com.doit.app.controller;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.MemberVo;
import com.doit.app.domain.QnaVo;
import com.doit.app.service.QnaService;
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
public class QnaController
{
    private final QnaService qnaService;



    // ============================================
    //  문의 폼 (독립 페이지)
    // ============================================

    // 문의하기 폼 (GET /qna/form)
    // 로그인 필수 - 세션 없으면 로그인 페이지로 이동
    @GetMapping("/qna/form")
    public String qnaForm(HttpSession session, Model model)
    {
        if (session.getAttribute("loginMember") == null) { return "redirect:/login"; }
        model.addAttribute("inquiryCategories", qnaService.getQnaTypes());
        return "user/qna_form";
    }


    // ============================================
    //  문의 내역 목록 (독립 페이지)
    // ============================================

    // 문의 내역 목록 (GET /qna/list?page=1)
    // 페이징: PaginateUtil 로 startRow/endRow 계산 후 Mapper 전달
    @GetMapping("/qna/list")
    public String qnaList(@RequestParam(name = "page", defaultValue = "1") int page,
                          HttpSession session, Model model)
    {
        MemberVo loginMember = (MemberVo) session.getAttribute("loginMember");
        if (loginMember == null) { return "redirect:/login"; }

        PaginateUtil pageInfo = qnaService.createPageInfo(page);
        List<QnaVo> qnaList  = qnaService.getQnasByMemberNo(loginMember.getMemberNo(), page, pageInfo);

        model.addAttribute("qnaList",  qnaList);
        model.addAttribute("pageInfo", pageInfo);
        return "user/qna_list";
    }


    // ============================================
    //  문의 등록
    // ============================================

    // 문의 등록 (POST /qna/question) - AJAX
    // 마이페이지 모달 & qna_form.jsp 공용 엔드포인트
    // memberNo 는 세션에서 가져와 덮어씀 (클라이언트 조작 방지)
    @PostMapping("/qna/question")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> submitQuestion(@RequestBody QnaVo qnaVo,
                                                               HttpSession session)
    {
        MemberVo loginMember = (MemberVo) session.getAttribute("loginMember");
        if (loginMember == null)
        {
            return ResponseEntity.status(401).body(Map.of("result", "unauthorized"));
        }

        qnaVo.setMemberNo(loginMember.getMemberNo());
        qnaService.submitQuestion(qnaVo);
        return ResponseEntity.ok(Map.of("result", "ok"));
    }


    // ============================================
    //  문의 상세
    // ============================================

    // 문의 상세 (GET /qna/detail/{qnaReqNo})
    // 로그인 필수, 본인 문의만 조회 가능 (Service 에서 memberNo 검증)
    @GetMapping("/qna/detail/{qnaReqNo}")
    public String qnaDetail(@PathVariable(name = "qnaReqNo") Long qnaReqNo,
                            HttpSession session, Model model)
    {
        MemberVo loginMember = (MemberVo) session.getAttribute("loginMember");
        if (loginMember == null) { return "redirect:/login"; }

        QnaVo qna = qnaService.getQnaDetail(qnaReqNo, loginMember.getMemberNo());
        if (qna == null) { return "redirect:/qna/list"; }

        model.addAttribute("qna", qna);
        return "user/qna_detail";
    }
}
