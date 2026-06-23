/*===============================================
    ChecklistVo.java
    - 여행 계획 체크리스트(준비물) 도메인 객체
    - PLAN_CHECKLIST 테이블 매핑
    - planDetail.jsp 의 ${item.xxx} 속성과 대응
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ChecklistVo
{
    private Long   no;           // PLAN_CHECKLIST.CHECKLIST_NO
    private Long   planNo;       // PLAN_CHECKLIST.TRAVEL_PLAN_NO
    private String content;      // PLAN_CHECKLIST.CONTENT
    private int    isChecked;    // PLAN_CHECKLIST.IS_CHECKED (0=미체크, 1=체크)
    private String createDt;     // TO_CHAR(CREATE_DT, 'YYYY-MM-DD')
}
