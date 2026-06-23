/*===============================================
    GuestVo.java
    - 여행 계획 게스트 도메인 객체
    - PLAN_GUEST JOIN MEMBER_ACTIVE JOIN TRAVEL_PLAN 결과 매핑
    - planDetail.jsp 의 ${g.xxx} 속성과 대응
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class GuestVo
{
    /* -- 읽기 전용 (JOIN 결과) -- */
    private Long    memberId;   // PLAN_GUEST.MEMBER_NO
    private String  nickname;   // MEMBER_ACTIVE.NICKNAME
    private boolean host;       // HOST_MEMBER_NO = MEMBER_NO 이면 true
    private boolean canEdit;    // PLAN_GUEST.CAN_EDIT (1=편집 가능, 0=읽기 전용)
    private String  joinedAt;   // TO_CHAR(PLAN_GUEST.CREATE_DT, 'YYYY-MM-DD')
}
