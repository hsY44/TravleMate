/*===============================================
    ContentReviewServiceImpl.java
    - 콘텐츠 리뷰 비즈니스 로직 구현체
    - ContentReviewMapper 를 통해 DB 연동
===============================================*/
package com.doit.app.service;

import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.ReviewVo;
import com.doit.app.mapper.ContentReviewMapper;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class ContentReviewServiceImpl implements ContentReviewService
{
    private final ContentReviewMapper mapper;

    // 비블라인드 리뷰 수 조회
    @Override
    public int getReviewCount(Long contentId)
    {
        int result = 0;
        try {
            result = mapper.selectReviewCount(contentId);
        } catch (Exception e) {
            log.info("getReviewCount : ", e);
        }
        return result;
    }

    // 비블라인드 리뷰 목록 조회 (페이징) - 탈퇴 회원 포함 (LEFT JOIN)
    @Override
    public List<ReviewVo> listContentReview(Map<String, Object> map)
    {
        List<ReviewVo> list = null;
        try {
            list = mapper.selectReviews(map);
        } catch (Exception e) {
            log.info("listContentReview : ", e);
        }
        return list;
    }

    // 리뷰 등록
    // - 동일 콘텐츠 주 1회 제한: 이번 주 작성 이력 있으면 false 반환
    // - 삽입 성공: true
    @Override
    public boolean addReview(ReviewVo reviewVo)
    {
        try {
            if (mapper.countWeeklyReview(reviewVo.getMemberNo(), reviewVo.getContentId()) > 0) return false;
            mapper.insertReview(reviewVo);
            return true;
        } catch (Exception e) {
            log.info("addReview : ", e);
            return false;
        }
    }

    // 리뷰 수정
    // - countReview 가 0 이면 (없거나 블라인드) false 반환
    @Override
    public boolean editReview(ReviewVo reviewVo)
    {
        try {
            if (mapper.countReview(reviewVo.getContentReviewNo(), reviewVo.getMemberNo()) == 0) return false;
            mapper.updateReview(reviewVo);
            return true;
        } catch (Exception e) {
            log.info("editReview : ", e);
            return false;
        }
    }

    // 리뷰 삭제
    // - countReview 가 0 이면 (없거나 블라인드) false 반환
    @Override
    public boolean removeReview(Long reviewNo, Long memberNo)
    {
        try {
            if (mapper.countReview(reviewNo, memberNo) == 0) return false;
            mapper.deleteReview(reviewNo, memberNo);
            return true;
        } catch (Exception e) {
            log.info("removeReview : ", e);
            return false;
        }
    }

    // 페이징 정보 생성
    @Override
    public PaginateUtil createPageInfo(int page, int page_size)
    {
        return new PaginateUtil(page, page_size);
    }
}
