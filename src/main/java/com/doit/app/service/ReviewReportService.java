package com.doit.app.service;

import com.doit.app.domain.ReviewReportTypeVO;
import com.doit.app.domain.ReviewReportVO;

import java.util.List;

public interface ReviewReportService {

    // 리뷰 신고 타입 조회
    public List<ReviewReportTypeVO> getReviewReportType();

    // 리뷰 신고 등록
    public int addReviewReport(ReviewReportVO reviewReport);
}
