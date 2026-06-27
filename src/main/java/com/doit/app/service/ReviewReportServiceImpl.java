package com.doit.app.service;

import com.doit.app.domain.ReviewReportTypeVO;
import com.doit.app.domain.ReviewReportVO;
import com.doit.app.mapper.ContentReviewMapper;
import com.doit.app.mapper.ReviewReportMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ReviewReportServiceImpl implements ReviewReportService {

    private final ReviewReportMapper mapper;
    private final ContentReviewMapper reviewMapper;

    // 리뷰 신고 타입 조회
    @Override
    public List<ReviewReportTypeVO> getReviewReportType() {
        List<ReviewReportTypeVO> list = null;
        try {
            list = mapper.selectReviewReportType();
        } catch (Exception e) {
            log.error("getReviewReportType : ", e);
        }
        return list;
    }

    // 리뷰 신고 등록
    // 1. REVIEW_REPORT INSERT
    // 2. CONTENT_REVIEW BLIND_YN 'N' → 'Y' (블라인드 처리)
    // ※ 두 작업이 원자적이어야 하므로 예외 발생 시 re-throw → @Transactional 롤백 보장
    @Transactional
    @Override
    public int addReviewReport(ReviewReportVO reviewReport) {
        int result = 0;
        try {
            result = mapper.insertReviewReport(reviewReport);
            reviewMapper.updateReviewBlind(reviewReport.getContentReviewNo());
        }  catch (Exception e) {
            log.error("addReviewReport : ", e);
            throw e;
        }
        return result;
    }
}
