package com.doit.app.controller;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.ReviewVo;
import com.doit.app.service.AdminReviewService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@Slf4j
public class AdminReviewController {

    private final AdminReviewService service;

    private boolean isAdminLoggedIn(HttpSession session)
    {
        return session.getAttribute("loginAdmin") != null;
    }

     // 관리자 리뷰 목록 페이지
    @GetMapping("/admin/reviews")
    public String adminListReviews(@RequestParam(name = "page", defaultValue = "1") int currentPage
            , @RequestParam(name = "schType", defaultValue = "none") String schType
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

            if (schType.equals("none")) {
                kwd = "";
            }

            Map<String, Object> map = new HashMap<String, Object>();
            map.put("schType", schType);
            map.put("kwd", kwd);

            dataCount = service.getReviewCount(map);

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

            List<ReviewVo> reviewList = service.listContentReview(map);
            String cp = req.getContextPath();
            String query = "";
            String listUrl = cp + "/admin/reviews";

            if (!kwd.isBlank()) {
                query += "?schType=" + schType + "&kwd=" + URLEncoder.encode(kwd, "UTF-8");
            }
            listUrl += query;

            model.addAttribute("reviewList", reviewList);
            model.addAttribute("page", currentPage);
            model.addAttribute("dataCount", dataCount);
            model.addAttribute("pageInfo", paginateUtil); // paging
            model.addAttribute("size", size);
            model.addAttribute("totalPage", totalPage);

            model.addAttribute("listUrl", listUrl);
            model.addAttribute("kwd", kwd);
            model.addAttribute("query", query);
        } catch (Exception e) {
            log.error("adminListReviews : ", e);
        }

        return "admin/reviews";
    }

}
