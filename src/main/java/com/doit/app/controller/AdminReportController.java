/*===============================================
    AdminReportController.java
    - 관리자 신고 내역 컨트롤러
===============================================*/
package com.doit.app.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Collections;

@RequiredArgsConstructor
@Slf4j
@Controller
public class AdminReportController
{
    private boolean isAdminLoggedIn(HttpSession session)
    {
        return session.getAttribute("loginAdmin") != null;
    }

    // GET /admin/reports
    @GetMapping("/admin/reports")
    public String reportList(@RequestParam(name="category", required = false) String category,
                             @RequestParam(name="status", required = false) String status,
                             HttpSession session, Model model)
    {
        if (!isAdminLoggedIn(session)) { return "redirect:/login"; }

        model.addAttribute("reports",          Collections.emptyList());
        model.addAttribute("reportCategories", Collections.emptyList());
        return "admin/reports";
    }
}
