package com.doit.app.mapper;

import com.doit.app.domain.ReviewReportTypeVO;
import com.doit.app.domain.ReviewReportVO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface ReviewReportMapper {

    // 리뷰 신고 타입 조회
    public List<ReviewReportTypeVO> selectReviewReportType();

    // 리뷰 신고 등록
    public int insertReviewReport(ReviewReportVO reviewReport);
}
