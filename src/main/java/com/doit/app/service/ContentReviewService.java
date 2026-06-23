/*===============================================
    ContentReviewService.java
    - 콘텐츠 리뷰 서비스 인터페이스
    - 구현체 : ContentReviewServiceImpl
===============================================*/
package com.doit.app.service;

import java.util.List;
import java.util.Map;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.ReviewVo;

public interface ContentReviewService
{
    // 비블라인드 리뷰 수 조회
    int getReviewCount(Long contentId);

    // 비블라인드 리뷰 목록 조회 (페이징) - 탈퇴 회원 포함
    List<ReviewVo> listContentReview(Map<String, Object> map);

    // 리뷰 등록 (동일 콘텐츠 주 1회 제한 포함)
    // - 성공: true / 이번 주 이미 작성: false
    boolean addReview(ReviewVo vo);

    // 리뷰 수정 (소유권/블라인드 확인 포함)
    // - 성공: true / 없거나 블라인드: false
    boolean editReview(ReviewVo vo);

    // 리뷰 삭제 (소유권/블라인드 확인 포함)
    // - 성공: true / 없거나 블라인드: false
    boolean removeReview(Long reviewNo, Long memberNo);

    // 페이징 정보 생성
    PaginateUtil createPageInfo(int page, int page_size);
}
