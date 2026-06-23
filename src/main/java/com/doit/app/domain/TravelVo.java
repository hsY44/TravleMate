/*===============================================
    TravelVo.java
    - 여행 계획 도메인 객체
    - TRAVEL_PLAN JOIN TRAVEL_THEME 결과 매핑
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class TravelVo
{
    private Long   travelPlanNo;    // 여행계획 고유번호  (TRAVEL_PLAN.TRAVEL_PLAN_NO)
    private String travelName;      // 여행계획 이름      (TRAVEL_PLAN.TRAVEL_NAME)
    private String travelStartDt;   // 여행 시작일        (TRAVEL_PLAN.TRAVEL_START_DT)
    private String travelEndDt;     // 여행 종료일        (TRAVEL_PLAN.TRAVEL_END_DT)
    private String travelThemeNm;   // 여행 테마명        (TRAVEL_THEME.TRAVEL_THEME_NM)
    private String outline;         // 개요               (TRAVEL_PLAN.OUTLINE)
}
