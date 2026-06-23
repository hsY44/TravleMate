/*===============================================
    ThemeVo.java
    - 여행 테마 도메인 객체
    - TRAVEL_THEME 테이블 매핑
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ThemeVo
{
    private String travelThemeCd;   // TRAVEL_THEME.TRAVEL_THEME_CD
    private String travelThemeNm;   // TRAVEL_THEME.TRAVEL_THEME_NM
    private int    planCount;        // 이 테마를 사용 중인 계획 수 (삭제 가능 여부 판단)
}
