/*===============================================
    ContentReviewMapper.java
    - 콘텐츠 리뷰 관련 MyBatis Mapper 인터페이스
    - contentReviewMapper.xml 과 연결
===============================================*/
package com.doit.app.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.doit.app.domain.ReviewVo;

@Mapper
public interface ContentReviewMapper
{
    // 비블라인드 리뷰 수 조회 (페이징 전체 건수용)
    int selectReviewCount(@Param("contentId") Long contentId);

    // 비블라인드 리뷰 목록 조회 (페이징) - 탈퇴 회원 포함 (LEFT JOIN)
    List<ReviewVo> selectReviews(Map<String, Object> map);

    // 리뷰 등록
    void insertReview(ReviewVo reviewVo);

    // 리뷰 수정 - 본인 리뷰이며 비블라인드인 경우만 반영
    void updateReview(ReviewVo vo);

    // 리뷰 삭제 - 본인 리뷰이며 비블라인드인 경우만 반영
    void deleteReview(@Param("reviewNo") Long reviewNo,
                      @Param("memberNo") Long memberNo);

    // 이번 주 동일 콘텐츠에 작성한 리뷰 수 확인 (주 1회 제한 체크용)
    // - 블라인드 포함, TRUNC(SYSDATE, 'IW') ~ +7 범위
    int countWeeklyReview(@Param("memberNo") Long memberNo,
                          @Param("contentId") Long contentId);

    // 리뷰 소유권 확인 (수정/삭제 전 서비스단에서 호출)
    // - 0: 없거나 본인 리뷰가 아니거나 블라인드 처리됨
    int countReview(@Param("reviewNo") Long reviewNo,
                    @Param("memberNo") Long memberNo);

    // 관리자 리뷰 블라인드 처리 (BLIND_YN 'N' → 'Y')
    int updateReviewBlind(@Param("reviewNo") Long reviewNo);
}
