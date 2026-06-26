package com.doit.app.controller;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.*;
import com.doit.app.service.AdminContentService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@Slf4j
public class AdminContentController {

    private final AdminContentService service;

    private boolean isAdminLoggedIn(HttpSession session)
    {
        return session.getAttribute("loginAdmin") != null;
    }

     // 관리자 컨텐츠 목록 페이지
    @GetMapping("/admin/contents")
    public String adminListContent(@RequestParam(name = "page", defaultValue = "1") int currentPage
            , @RequestParam(name = "category", defaultValue = "all") String category
            , @RequestParam(name = "kwd", defaultValue = "") String kwd
            , HttpSession session
            , Model model
            , HttpServletRequest req) {

        try {
            if (!isAdminLoggedIn(session)) { return "redirect:/login"; }

            int size = 10;
            int totalPage = 0;
            int dataCount = 0;
            int offset = 0;

            kwd = URLDecoder.decode(kwd, "utf-8");

            Map<String, Object> map = new HashMap<String, Object>();
            map.put("category", category);		// 카테고리
            map.put("kwd", kwd);

            List<ContentCategoryVO> cateList = service.listCategory();

            dataCount = service.dataCount(map);

            // 페이징
            PaginateUtil paginateUtil = service.createPageInfo(currentPage, size);
            paginateUtil.setTotalCount(dataCount);

            if (dataCount > 0) {
                totalPage = paginateUtil.getTotalPages();
                currentPage = Math.max(1, Math.min(currentPage, totalPage));
                offset = (currentPage - 1) * size;
            }

            map.put("offset", offset);
            map.put("size", size);

            List<ContentVO> contentList = service.listContent(map);
            String cp = req.getContextPath();
            String query = "";
            String listUrl = cp + "/admin/contents";

            if (!category.isBlank() && !category.equals("all")) {
                query = "category=" + category;
            }
            if (!kwd.isBlank()) {
                query += query.isEmpty() ? "" : "&";
                query += "kwd=" + URLEncoder.encode(kwd, "UTF-8");
            }
            if (!query.isEmpty()) {
                listUrl += "?" + query;
            }

            model.addAttribute("contentList", contentList);
            model.addAttribute("cateList", cateList);
            model.addAttribute("page", currentPage);
            model.addAttribute("dataCount", dataCount);
            model.addAttribute("pageInfo", paginateUtil); // paging
            model.addAttribute("size", size);
            model.addAttribute("totalPage", totalPage);

            model.addAttribute("listUrl", listUrl);
            model.addAttribute("category", category);
            model.addAttribute("kwd", kwd);
            model.addAttribute("query", query);
        } catch (Exception e) {
            log.error("admin/contents : ", e);
        }

        return "admin/contents";
    }

    // 컨텐츠 상세
    @GetMapping("/admin/contents/{contentId}")
    public String detailContent(@PathVariable(name = "contentId") Long contentId
            , @RequestParam(name = "page", defaultValue = "1") String page
            , @RequestParam(name = "category", defaultValue = "all") String category
            , @RequestParam(name = "kwd", defaultValue = "") String kwd
            , HttpSession session
            , Model model) {

        String query = "page=" + page;

        try {
            if (!isAdminLoggedIn(session)) { return "redirect:/login"; }

            kwd = URLDecoder.decode(kwd, "utf-8");

            // 카테고리
            if (! category.isBlank()) {
                query += "&category=" + category;
            }

            // 키워드
            if (! kwd.isBlank()) {
                query += "&kwd=" + URLEncoder.encode(kwd, "utf-8");
            }

            ContentVO content = service.getContentDetail(contentId);

            List<ContentImageVO> images = service.getContentImages(contentId);
            if (content != null && content.getFirstImage() != null) {
                images.addFirst(new ContentImageVO(0L, content.getFirstImage(), content.getTitle()));
            }

            model.addAttribute("content", content);
            model.addAttribute("images", images);
            model.addAttribute("query", query);

        } catch (Exception e) {
            log.error("admin/contentDetail : ", e);
        }

        return "admin/contentDetail";
    }
}
