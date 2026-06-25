/*===============================================
    ScheduleVo.java
    - 여행 일정(일정 카드) 도메인 객체
    - TRAVEL_ITINERARY + ITINERARY_EXPENSE + CONTENT JOIN 결과 매핑
    - planDetail.jsp 의 ${sc.xxx} 속성과 대응
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class ScheduleVo
{
    /* -- 읽기/쓰기 공통 -- */
    private Long   id;              // TRAVEL_ITINERARY.TRAVEL_ITINERARY_NO
    private Long   planNo;          // TRAVEL_ITINERARY.TRAVEL_PLAN_NO
    private String itineraryDt;     // TRAVEL_ITINERARY.ITINERARY_DT  (yyyy-MM-dd)
    private String time;            // TRAVEL_ITINERARY.ITINERARY_TIME (HH:mm)
    private String title;           // TRAVEL_ITINERARY.ITINERARY_TITLE
    private String content;         // TRAVEL_ITINERARY.MEMO
    private Long   contentNo;        // TRAVEL_ITINERARY.CONTENT_NO (선택)
    private String mapX;             // TRAVEL_ITINERARY.MAP_X — Kakao 검색 장소 경도 (contentNo 없을 때만 저장)
    private String mapY;             // TRAVEL_ITINERARY.MAP_Y — Kakao 검색 장소 위도 (contentNo 없을 때만 저장)

    /* -- 읽기 전용 (JOIN 결과) -- */
    private String contentName;     // CONTENT.TITLE
    private String contentImage;    // CONTENT.FIRSTIMAGE
    // mapX, mapY 조회 시: NVL(C.MAPX, TI.MAP_X) — CONTENT 좌표 우선, 없으면 MAP_X/MAP_Y 사용
    private long   cost;            // ITINERARY_EXPENSE.EXPENSE_AMT (없으면 0)
    private long   estimatedCost;   // ITINERARY_EXPENSE.ESTIMATED_AMT (없으면 0)
    private String costCategory;    // ITINERARY_EXPENSE_TYPE.EXPENSE_TYPE_NM
    private String paymentMethod;   // ITINERARY_EXPENSE.PAYMENT_METHOD
    private String expenseMemo;     // ITINERARY_EXPENSE.EXPENSE_MEMO

    /* -- 컨트롤러 계산 필드 -- */
    private int    dayIndex;        // 0-based 일차 인덱스  (컨트롤러에서 계산)
    private String dayLabel;        // "Day N (MM-dd)"       (컨트롤러에서 계산)
}
