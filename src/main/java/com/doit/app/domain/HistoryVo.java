/*===============================================
    HistoryVo.java
    - 여행 일정 편집 이력 도메인 객체
    - TRAVEL_ITINERARY_HIST JOIN ACTION_TYPE JOIN PLAN_GUEST JOIN MEMBER_ACTIVE 결과 매핑
    - planDetail.jsp 의 ${h.xxx} 속성과 대응
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class HistoryVo
{
    private String type;        // ACTION_TYPE.ACTION_TYPE_NM  (추가 / 수정 / 삭제)
    private String target;      // TRAVEL_ITINERARY.ITINERARY_TITLE (히스토리 기록 시점 제목)
    private String editor;      // MEMBER_ACTIVE.NICKNAME
    private String editedAt;    // TO_CHAR(HIST_DT, 'YYYY-MM-DD HH24:MI')
}
