/*===============================================
    FaqController.java
    - 사용자 FAQ 컨트롤러
    - FAQ 목록 (카테고리 필터 포함)
===============================================*/
package com.doit.app.controller;

import com.doit.app.service.FaqService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@RequiredArgsConstructor
@Slf4j
@Controller
@RequestMapping("/faq")
public class FaqController
{
    private final FaqService faqService;


    // FAQ 목록 (GET /faq/list?type=xxx)
    // type 없으면 전체 조회
    @GetMapping("/list")
    public String faqList(@RequestParam(name = "type", required = false) String type,
                          Model model)
    {
        model.addAttribute("faqTypes",     faqService.getFaqTypes());
        model.addAttribute("faqs",         faqService.getFaqs(type));
        model.addAttribute("selectedType", type);
        return "user/faq_list";
    }
}
