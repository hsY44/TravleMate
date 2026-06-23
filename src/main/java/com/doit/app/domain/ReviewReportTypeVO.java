package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class ReviewReportTypeVO {
    private Long  reportTypeCd;     // 리뷰 신고 타입 번호
    private String reportTypeNm;    // 리뷰 신고 타입명
}
