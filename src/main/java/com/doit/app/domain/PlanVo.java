/*===============================================
    PlanVo.java
    - 여행 계획 도메인 객체
    - plans.jsp / planDetail.jsp 의 ${plan.xxx} 속성과 대응
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class PlanVo
{
    private Long   id;              // TRAVEL_PLAN.TRAVEL_PLAN_NO
    private Long   hostMemberNo;    // TRAVEL_PLAN.HOST_MEMBER_NO
    private String title;           // TRAVEL_PLAN.TRAVEL_NAME
    private String theme;           // TRAVEL_THEME.TRAVEL_THEME_NM
    private String startDate;       // TO_CHAR(TRAVEL_START_DT, 'YYYY-MM-DD')
    private String endDate;         // TO_CHAR(TRAVEL_END_DT,   'YYYY-MM-DD')
    private String overview;        // TRAVEL_PLAN.OUTLINE
    private int    dayCount;        // TRAVEL_END_DT - TRAVEL_START_DT + 1
    private int    guestCount;      // COUNT(*) FROM PLAN_GUEST
    private String lastEditedAt;    // TO_CHAR(REVISION_DT, 'YYYY-MM-DD')
    private String inviteCode;      // TRAVEL_INVITATION.INVITE_CODE
    private int    isPublic;        // TRAVEL_PLAN.IS_PUBLIC (1=공개, 0=비공개)
}
