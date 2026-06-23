/*===============================================
    PlanDatesVo.java
    - 여행 계획 시작/종료일 VO
    - 일정 편집 가능 기간 판단용 (M6)
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PlanDatesVo
{
    private String startDt;  // TO_CHAR(TRAVEL_START_DT, 'YYYY-MM-DD')
    private String endDt;    // TO_CHAR(TRAVEL_END_DT,   'YYYY-MM-DD')
}
