/*===============================================
    CostSummaryVo.java
    - 여행 비용 카테고리별 합계 도메인 객체
    - ITINERARY_EXPENSE GROUP BY EXPENSE_TYPE_NM 결과 매핑
    - planDetail.jsp 의 ${cost.xxx} 속성과 대응
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class CostSummaryVo
{
    private String category;         // ITINERARY_EXPENSE_TYPE.EXPENSE_TYPE_NM
    private long   total;            // SUM(ITINERARY_EXPENSE.EXPENSE_AMT)
    private long   estimatedTotal;   // SUM(ITINERARY_EXPENSE.ESTIMATED_AMT)
}
