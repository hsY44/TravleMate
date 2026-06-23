package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class ReviewReportVO extends ReviewReportTypeVO {
    private Long reviewReportNo;       // REVIEW_REPORT_NO (PK)
    private Long reporterMemberNo;     // REPORTER_MEMBER_NO (신고자 회원 번호)
    private Long contentReviewNo;      // CONTENT_REVIEW_NO (리뷰 번호)
    private String reportDt;           // REPORT_DT (신고 일시)
    private String reportComment;      // REPORT_COMMENT (신고 내용)
    private String processYn;          // PROCESS_YN (처리 여부: Y/N)
}
