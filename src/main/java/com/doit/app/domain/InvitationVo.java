/*===============================================
    InvitationVo.java
    - 받은 초대 도메인 객체 (TRAVEL_INVITATION)
    - 마이페이지 초대 목록 / 수락/거절 처리용
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class InvitationVo
{
    private Long   invitationNo;    // TRAVEL_INVITATION.TRAVEL_INVITATION_NO
    private Long   planNo;          // TRAVEL_INVITATION.TRAVEL_PLAN_NO
    private Long   inviteeMemberNo; // TRAVEL_INVITATION.INVITEE_MEMBER_NO
    private String planTitle;       // TRAVEL_PLAN.TRAVEL_NAME (JOIN)
    private String hostNickname;    // MEMBER_ACTIVE.NICKNAME (호스트 JOIN)
    private String inviteStatus;    // TRAVEL_INVITATION.INVITE_STATUS
    private String createDt;        // TO_CHAR(CREATE_DT, 'YYYY-MM-DD')
}
