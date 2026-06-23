/*===============================================
    AdminFaqController.java
    - 관리자 FAQ 관리 컨트롤러
    - FAQ 카테고리 관리, FAQ CRUD
    - /admin/faqs - 사이드바 'faqs' 메뉴에 연결
===============================================*/
package com.doit.app.controller;

import com.doit.app.domain.AdminVo;
import com.doit.app.domain.FaqTypeVo;
import com.doit.app.domain.FaqVo;
import com.doit.app.service.AdminFaqService;
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
public class AdminFaqController
{
    private final AdminFaqService adminFaqService;


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
    //  FAQ 카테고리 관리
    // ============================================

    // GET /admin/faqType
    @GetMapping("/admin/faqType")
    public String faqTypePage(HttpSession session, Model model)
    {
        if (!isAdminLoggedIn(session)) { return "redirect:/login"; }
        model.addAttribute("faqTypes", adminFaqService.getFaqTypes());
        return "admin/faqType";
    }

    // POST /admin/faqType - 카테고리 등록 (AJAX)
    @PostMapping("/admin/faqType")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> addFaqType(@RequestBody FaqTypeVo vo,
                                                           HttpSession session)
    {
        if (!isAdminLoggedIn(session)) { return ResponseEntity.status(401).body(Map.of("result", "unauthorized")); }
        int rows = adminFaqService.addFaqType(vo);
        return ResponseEntity.ok(Map.of("result", rows > 0 ? "ok" : "fail"));
    }

    // PUT /admin/faqType/{cd} - 카테고리 이름 수정 (AJAX)
    @PutMapping("/admin/faqType/{cd}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> editFaqType(@PathVariable(name = "cd") String cd,
                                                            @RequestBody  FaqTypeVo vo,
                                                            HttpSession session)
    {
        if (!isAdminLoggedIn(session)) { return ResponseEntity.status(401).body(Map.of("result", "unauthorized")); }
        vo.setFaqTypeCd(cd);
        int rows = adminFaqService.editFaqType(vo);
        return ResponseEntity.ok(Map.of("result", rows > 0 ? "ok" : "fail"));
    }


    // ============================================
    //  FAQ 목록 (GET /admin/faqs - 사이드바 연결)
    // ============================================

    @GetMapping("/admin/faqs")
    public String faqList(HttpSession session, Model model)
    {
        if (!isAdminLoggedIn(session)) { return "redirect:/login"; }
        model.addAttribute("faqs",     adminFaqService.getAllFaqs());
        model.addAttribute("faqTypes", adminFaqService.getFaqTypes());
        return "admin/faq";
    }


    // ============================================
    //  FAQ CRUD (AJAX)
    // ============================================

    // POST /admin/faq - 등록
    @PostMapping("/admin/faq")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> addFaq(@RequestBody Map<String, String> body,
                                                       HttpSession session)
    {
        if (!isAdminLoggedIn(session)) { return ResponseEntity.status(401).body(Map.of("result", "unauthorized")); }
        int rows = adminFaqService.addFaq(
            adminNo(session),
            body.get("faqTypeCd"),
            body.get("faqQuestion"),
            body.get("faqAnswer")
        );
        return ResponseEntity.ok(Map.of("result", rows > 0 ? "ok" : "fail"));
    }

    // PUT /admin/faq/{faqNo} - 수정
    @PutMapping("/admin/faq/{faqNo}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> editFaq(@PathVariable(name = "faqNo") Long faqNo,
                                                        @RequestBody  Map<String, String> body,
                                                        HttpSession session)
    {
        if (!isAdminLoggedIn(session)) { return ResponseEntity.status(401).body(Map.of("result", "unauthorized")); }
        int rows = adminFaqService.editFaq(
            faqNo,
            body.get("faqTypeCd"),
            body.get("faqQuestion"),
            body.get("faqAnswer")
        );
        return ResponseEntity.ok(Map.of("result", rows > 0 ? "ok" : "fail"));
    }

    // DELETE /admin/faq/{faqNo} - 삭제
    @DeleteMapping("/admin/faq/{faqNo}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteFaq(@PathVariable(name = "faqNo") Long faqNo,
                                                          HttpSession session)
    {
        if (!isAdminLoggedIn(session)) { return ResponseEntity.status(401).body(Map.of("result", "unauthorized")); }
        int rows = adminFaqService.removeFaq(faqNo);
        return ResponseEntity.ok(Map.of("result", rows > 0 ? "ok" : "fail"));
    }
}
