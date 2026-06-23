/*===============================================
    AdminQnaController.java
    - 관리자 문의 관리 컨트롤러
    - 문의 카테고리 관리, 문의 목록/상세/답변
===============================================*/
package com.doit.app.controller;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.AdminVo;
import com.doit.app.domain.QnaTypeVo;
import com.doit.app.domain.QnaVo;
import com.doit.app.service.AdminQnaService;
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
public class AdminQnaController
{
    private final AdminQnaService adminQnaService;


    private boolean isAdminLoggedIn(HttpSession session)
    {
        return session.getAttribute("loginAdmin") != null;
    }

    private Long adminNo(HttpSession session)
    {
        AdminVo admin = (AdminVo) session.getAttribute("loginAdmin");
        return admin.getAdminNo();
    }


    // ============================================
    //  문의 카테고리 (QNA_TYPE)
    // ============================================

    // GET /admin/qnaType - 문의 카테고리 관리 페이지
    @GetMapping("/admin/qnaType")
    public String qnaTypePage(HttpSession session, Model model)
    {
        if (!isAdminLoggedIn(session)) { return "redirect:/login"; }
        model.addAttribute("qnaTypes", adminQnaService.getQnaTypes());
        return "admin/qnaType";
    }

    // POST /admin/qnaType - 문의 카테고리 등록 (AJAX)
    @PostMapping("/admin/qnaType")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> addQnaType(@RequestBody QnaTypeVo vo,
                                                           HttpSession session)
    {
        if (!isAdminLoggedIn(session)) { return ResponseEntity.status(401).body(Map.of("result", "unauthorized")); }
        adminQnaService.addQnaType(vo);
        return ResponseEntity.ok(Map.of("result", "ok"));
    }

    // PUT /admin/qnaType/{cd} - 문의 카테고리 수정 (AJAX)
    @PutMapping("/admin/qnaType/{cd}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> editQnaType(@PathVariable(name = "cd") String cd,
                                                            @RequestBody QnaTypeVo vo,
                                                            HttpSession session)
    {
        if (!isAdminLoggedIn(session)) { return ResponseEntity.status(401).body(Map.of("result", "unauthorized")); }
        vo.setQnaTypeCd(cd);
        adminQnaService.editQnaType(vo);
        return ResponseEntity.ok(Map.of("result", "ok"));
    }


    // ============================================
    //  문의 목록
    // ============================================

    // GET /admin/qnas?page=1
    @GetMapping("/admin/qnas")
    public String qnaList(@RequestParam(name = "page", defaultValue = "1") int page
                          ,HttpSession session
                          , Model model) {
        if (!isAdminLoggedIn(session))
        {
        	return "redirect:/login";
        }

        PaginateUtil pageInfo  = adminQnaService.createPageInfo(page);
        List<QnaVo> qnaList   = adminQnaService.getAllQnas(page, pageInfo);

        model.addAttribute("qnaList",  qnaList);
        model.addAttribute("pageInfo", pageInfo);
        return "admin/qna";
    }


    // ============================================
    //  문의 상세 / 답변 (AJAX)
    // ============================================

    // GET /admin/qna/{qnaReqNo} - 드로어 상세용
    @GetMapping("/admin/qna/{qnaReqNo}")
    @ResponseBody
    public ResponseEntity<QnaVo> qnaDetail(@PathVariable(name = "qnaReqNo") Long qnaReqNo,
                                            HttpSession session)
    {
        if (!isAdminLoggedIn(session)) { return ResponseEntity.status(401).build(); }
        QnaVo qna = adminQnaService.getQnaDetail(qnaReqNo);
        if (qna == null) { return ResponseEntity.notFound().build(); }
        return ResponseEntity.ok(qna);
    }

    // POST /admin/qna/{qnaReqNo}/answer - 답변 등록 (AJAX)
    @PostMapping("/admin/qna/{qnaReqNo}/answer")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> submitAnswer(@PathVariable(name = "qnaReqNo") Long qnaReqNo,
                                                             @RequestBody Map<String, String> body,
                                                             HttpSession session)
    {
        if (!isAdminLoggedIn(session)) { return ResponseEntity.status(401).body(Map.of("result", "unauthorized")); }

        String ansContent = body.get("ansContent");
        if (ansContent == null || ansContent.isBlank())
        {
            return ResponseEntity.badRequest().body(Map.of("result", "empty"));
        }

        adminQnaService.submitAnswer(qnaReqNo, adminNo(session), ansContent);
        return ResponseEntity.ok(Map.of("result", "ok"));
    }
}
