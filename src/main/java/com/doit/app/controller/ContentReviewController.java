package com.doit.app.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.doit.app.domain.*;
import com.doit.app.service.ReviewReportService;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import com.doit.app.common.PaginateUtil;
import com.doit.app.service.ContentReviewService;

import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Controller
@RequiredArgsConstructor
@Slf4j
@RequestMapping("/contents/review")
public class ContentReviewController
{

	private final ContentReviewService service;
    private final ReviewReportService reviewReportService;

    /**
     * 리뷰 조회
     * @param contentId 컨텐츠 ID
     * @param currentPage 리뷰 현재 페이지
     * @return 리뷰 목록과 페이징 데이터
     */
	@GetMapping("/list")
	@ResponseBody
	public ApiResponse<?> listContentReview(@RequestParam(name = "contentId") Long contentId
			, @RequestParam(name = "page", defaultValue = "1") int currentPage) {
		
		try {
			int size = 5;
            int totalPage = 0;
			int dataCount = 0;
            int offset = 0;
	    	
			Map<String, Object> map = new HashMap<String, Object>();
			
			map.put("contentId", contentId);

            dataCount = service.getReviewCount(contentId);

            // 페이징
            PaginateUtil pageInfo = service.createPageInfo(currentPage, size);
			pageInfo.setTotalCount(dataCount);

            if (dataCount > 0) {
                totalPage = pageInfo.getTotalPages();
                currentPage = Math.max(1, Math.min(currentPage, totalPage));
                offset = (currentPage - 1) * size;
            }

			map.put("offset", offset);
			map.put("size", size);
			
			List<ReviewVo> list = service.listContentReview(map);

			PageResponse<PaginateUtil, ReviewVo> response = new PageResponse<PaginateUtil, ReviewVo>(pageInfo, list);

            return ApiResponse.success(response);
		} catch (Exception e) {
            log.info("listContentReview : ", e);
		}

        return ApiResponse.fail(500, "실패");
	}

    /**
     * 리뷰 등록
     * @param contentId 컨텐츠 ID
     * @param body content, rating
     * @param session 로그인 회원 정보
     * @return 등록한 리뷰 정보
     */
    @PostMapping("/{contentId}/add")
    public ResponseEntity<Map<String, Object>> addReview(
            @PathVariable(name = "contentId") Long contentId,
            @RequestBody Map<String, Object> body,
            HttpSession session)
    {
        MemberVo loginMember = (MemberVo) session.getAttribute("loginMember");
        if (loginMember == null)
            return ResponseEntity.status(401).build();

        ReviewVo vo = new ReviewVo();
        vo.setContentId(contentId);
        vo.setMemberNo(loginMember.getMemberNo());
        vo.setReviewComment((String) body.get("content"));
        vo.setRating(Integer.parseInt(body.get("rating").toString()));

        // 주 1회 제한 확인 - false: 이번 주 이미 작성
        boolean added = service.addReview(vo);
        if (!added) return ResponseEntity.status(409).body(Map.<String, Object>of("msg", "이번 주에 이미 리뷰를 작성했습니다."));
        return ResponseEntity.ok(Map.of(
                "id",        vo.getContentReviewNo(),
                "nickname",  loginMember.getNickname(),
                "content",   vo.getReviewComment(),
                "rating",    vo.getRating(),
                "createdAt", java.time.LocalDate.now().toString(),
                "memberId",  loginMember.getMemberNo()
        ));
    }

    /**
     * 리뷰 수정
     * @param contentId 컨텐츠 ID
     * @param reviewNo 리뷰 번호
     * @param body content, rating
     * @param session 로그인 회원 정보
     * @return ResponseEntity.status
     */
    @PutMapping("{contentId}/edit/{reviewNo}")
    public ResponseEntity<Void> editReview(
            @PathVariable(name = "contentId") Long contentId,
            @PathVariable(name = "reviewNo") Long reviewNo,
            @RequestBody Map<String, Object> body,
            HttpSession session)
    {
        MemberVo loginMember = (MemberVo) session.getAttribute("loginMember");
        if (loginMember == null)
            return ResponseEntity.status(401).build();

        ReviewVo vo = new ReviewVo();
        vo.setContentReviewNo(reviewNo);
        vo.setMemberNo(loginMember.getMemberNo());
        vo.setReviewComment((String) body.get("content"));
        vo.setRating(Integer.parseInt(body.get("rating").toString()));

        boolean ok = service.editReview(vo);
        return ok ? ResponseEntity.ok().build() : ResponseEntity.status(403).build();
    }

    /**
     * 리뷰 삭제
     * @param contentId 컨텐츠 ID
     * @param reviewNo 리뷰 번호
     * @param session 로그인 회원 정보
     * @return ResponseEntity.status
     */
    @DeleteMapping("{contentId}/delete/{reviewNo}")
    public ResponseEntity<Void> deleteReview(
            @PathVariable(name = "contentId") Long contentId,
            @PathVariable(name = "reviewNo") Long reviewNo,
            HttpSession session)
    {
        MemberVo loginMember = (MemberVo) session.getAttribute("loginMember");
        if (loginMember == null)
            return ResponseEntity.status(401).build();

        boolean ok = service.removeReview(reviewNo, loginMember.getMemberNo());
        return ok ? ResponseEntity.ok().build() : ResponseEntity.status(403).build();
    }

    /**
     * 리뷰 신고 등록
     * @param reviewReportVO reporterMemberNo, contentReviewNo, reportTypeCd, reportComment
     * @param session 로그인 회원 정보
     * @return result: ok/fail
     */
    @PostMapping("/addReport")
    public ResponseEntity<Map<String, Object>> addReviewReport(
            @RequestBody ReviewReportVO reviewReportVO,
            HttpSession session)
    {

        MemberVo loginMember = (MemberVo) session.getAttribute("loginMember");
        if (loginMember == null)
            return ResponseEntity.status(401).build();

        reviewReportVO.setReporterMemberNo(loginMember.getMemberNo());

        int rows = reviewReportService.addReviewReport(reviewReportVO);
        return ResponseEntity.ok(Map.of("result", rows > 0 ? "ok" : "fail"));
    }
}
