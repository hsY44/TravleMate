package com.doit.app.service;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.ReviewVo;

import java.util.List;
import java.util.Map;

public interface AdminReviewService {

	// 데이터 개수
	public int getReviewCount(Map<String,Object> map);
	
	// 컨텐츠 리뷰 조회
	public List<ReviewVo> listContentReview(Map<String, Object> map);

    // 특정 리뷰를 블라인드 처리 (BLIND_YN = 'Y')
    public int updateReviewBlind(Long reviewNo);

	// 페이징
	public PaginateUtil createPageInfo(int page, int page_size);
}
