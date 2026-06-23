/*===============================================
    AdminCategoryController.java
    - 카테고리 관리 통합 페이지
    - 편집종류(ACTION_TYPE) + 문의카테고리(QNA_TYPE) + FAQ카테고리(FAQ_TYPE) + 테마(TRAVEL_THEME)
===============================================*/
package com.doit.app.controller;

import com.doit.app.service.AdminFaqService;
import com.doit.app.service.AdminThemeService;
import com.doit.app.service.ItineraryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@RequiredArgsConstructor
@Slf4j
@Controller
public class AdminCategoryController
{
    private final ItineraryService  itineraryService;
    private final AdminFaqService   adminFaqService;
    private final AdminThemeService adminThemeService;


    private boolean isAdminLoggedIn(HttpSession session)
    {
        return session.getAttribute("loginAdmin") != null;
    }

    // GET /admin/category - 카테고리 관리 통합 페이지
    @GetMapping("/admin/category")
    public String categoryPage(HttpSession session, Model model)
    {
        if (!isAdminLoggedIn(session)) { return "redirect:/login"; }

        model.addAttribute("actionTypes", itineraryService.getAllActionTypes());
        model.addAttribute("faqTypes",    adminFaqService.getFaqTypes());
        model.addAttribute("themes",      adminThemeService.getAllThemes());

        return "admin/category";
    }
}
