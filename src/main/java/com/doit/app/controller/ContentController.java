package com.doit.app.controller;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import com.doit.app.domain.*;
import com.doit.app.mapper.TravelMapper;
import com.doit.app.service.ReviewReportService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.doit.app.common.PaginateUtil;
import com.doit.app.service.ContentService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/contents/*")
public class ContentController
{
	private final ContentService service;
    private final ReviewReportService reportService;
    private final TravelMapper travelMapper;

    /**
     * GET /contents/search?kwd=검색어&category=39&addr=서울
     * - 일정 추가 모달에서 컨텐츠를 검색하는 AJAX API
     * - 응답: [{contentId, title, addr1, contentTypeId, contentDiv}, ...] 최대 10건
     */
    @GetMapping("search")
    @ResponseBody
    public ResponseEntity<List<Map<String, Object>>> searchContents(
            @RequestParam(name = "kwd",      defaultValue = "") String kwd,
            @RequestParam(name = "category", defaultValue = "all") String category,
            @RequestParam(name = "addr",     defaultValue = "") String addr)
    {
        Map<String, Object> params = new HashMap<>();
        params.put("category", category);
        params.put("kwd",      kwd.trim());
        params.put("addr",     addr.trim());
        params.put("offset",   0);
        params.put("size",     10);

        List<ContentVO> list = service.listContent(params);
        List<Map<String, Object>> result = list.stream()
                .map(c -> {
                    Map<String, Object> m = new HashMap<>();
                    m.put("contentId",     c.getContentId());
                    m.put("title",         c.getTitle());
                    m.put("addr1",         c.getAddr1());
                    m.put("firstImage",    c.getFirstImage());
                    m.put("contentTypeId", c.getContentTypeId());
                    m.put("contentDiv",    c.getContentDiv());
                    return m;
                })
                .collect(Collectors.toList());

        return ResponseEntity.ok(result);
    }
	
    // 컨텐츠 목록
    @GetMapping("list")
    public String listContent(@RequestParam(name = "page", defaultValue = "1") int currentPage
    		, @RequestParam(name = "category", defaultValue = "all") String category
    		, @RequestParam(name = "kwd", defaultValue = "") String kwd
    		, HttpSession session
    		, Model model
    		, HttpServletRequest req) throws Exception {
    	
    	try {

    		// 3 * 3 카드 형식이라서 9로 설정
	    	int size = 9;
	    	int totalPage = 0;
	    	int dataCount = 0;
            int offset = 0;

			kwd = URLDecoder.decode(kwd, "utf-8");
	    	
			Map<String, Object> map = new HashMap<String, Object>();
			
			// 로그인되었을 경우 session 에서 memberNo 가져오기
    		MemberVo loginMember = (MemberVo) session.getAttribute("loginMember");
    		Long memberNo = null;
    		if (loginMember != null && loginMember.getMemberNo() != null) {
    			memberNo = loginMember.getMemberNo();
    		}
            session.setAttribute("memberNo", memberNo);
    		map.put("memberNo", memberNo);
			
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
			String listUrl = cp + "/contents/list";

			if (!category.isBlank() && !category.equals("all")) {
				query = "category=" + category;
				query = listUrl.contains("?") ? "&" : "?" + query;
			}
			if (!kwd.isBlank()) {
				query += query.contains("?") ? "&" : "?";
				//query += "schType=" + schType + "&kwd=" + URLEncoder.encode(kwd, "UTF-8");
				query += "kwd=" + URLEncoder.encode(kwd, "UTF-8");
			}
			listUrl += query;

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
			log.info("contents/list : ", e);
			throw e;
		}
    	
        return "user/content/list";
    }

    // 컨텐츠 상세
    @GetMapping("{contentId}")
    public String detailContent(@PathVariable(name = "contentId") Long contentId
			, @RequestParam(name = "page", defaultValue = "1") String page
    		, @RequestParam(name = "category", defaultValue = "all") String category
    		, @RequestParam(name = "kwd", defaultValue = "") String kwd
    		, HttpSession session
			, Model model) {

		String query = "page=" + page;
		
        try {
        	
        	kwd = URLDecoder.decode(kwd, "utf-8");
        	
        	// 카테고리
        	if (! category.isBlank()) {
        		query += "&category=" + category;
        	}
        	
        	// 키워드
        	if (! kwd.isBlank()) {
        		query += "&kwd=" + URLEncoder.encode(kwd, "utf-8");
        	}
        	
			// 로그인되었을 경우 session 에서 memberNo 가져오기
    		MemberVo loginMember = (MemberVo) session.getAttribute("loginMember");
    		Long memberNo = null;
    		if (loginMember != null && loginMember.getMemberNo() != null) {
    			memberNo = loginMember.getMemberNo();
    		}
            session.setAttribute("memberNo", memberNo);
        	
            ContentVO content = service.getContentDetail(contentId, memberNo);

            List<ContentImageVO> images = service.getContentImages(contentId);
            if (content != null && content.getFirstImage() != null) {
                images.addFirst(new ContentImageVO(0L, content.getFirstImage(), content.getTitle()));
            }

            // 리뷰 신고 카테고리
            List<ReviewReportTypeVO> reportCategories = reportService.getReviewReportType();

            // 로그인 회원의 여행 계획 목록
            if (loginMember != null) {
                List<PlanVo> myPlans = travelMapper.selectMyPlans(memberNo, null, null, null);

                List<Map<String, Object>> planList = new ArrayList<>();

                for (PlanVo plan : myPlans) {
                    List<LocalDate> dateList = new ArrayList<>();
                    LocalDate start = LocalDate.parse(plan.getStartDate());
                    for (int i = 0; i < plan.getDayCount(); i++) {
                        dateList.add(start.plusDays(i));
                    }
                    Map<String, Object> map = new HashMap<>();
                    map.put("plan", plan);
                    map.put("dateList", dateList);
                    planList.add(map);
                }

                model.addAttribute("myPlans", planList);
            }

            model.addAttribute("content", content);
            model.addAttribute("reportCategories", reportCategories);
            model.addAttribute("images", images);
			model.addAttribute("query", query);

        } catch (Exception e) {
            log.info("contents detail : ", e);
        }

        return "user/content/contentDetail";
    }

    // -- 즐겨찾기 토글 ---------------------------------------------
    @PostMapping("{contentId}/bookmark")
    public ResponseEntity<Map<String, Object>> toggleBookmark(
            @PathVariable(name = "contentId") Long contentId,
            HttpSession session)
    {
        MemberVo loginMember = (MemberVo) session.getAttribute("loginMember");
        if (loginMember == null)
            return ResponseEntity.status(401).build();

        boolean favorited = service.toggleBookmark(loginMember.getMemberNo(), contentId);
        return ResponseEntity.ok(Map.of("favorited", favorited));
    }
}