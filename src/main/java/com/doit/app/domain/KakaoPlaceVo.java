/*===============================================
    KakaoPlaceVo.java
    - Kakao Local API 장소 검색 결과 VO
    - KakaoLocalService.search() 반환값
    - /kakao/places 엔드포인트 응답 JSON으로 직렬화
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class KakaoPlaceVo
{
    private String placeName;    // place_name  — 장소명 (DB: TRAVEL_ITINERARY.ITINERARY_TITLE 후보)
    private String addressName;  // address_name — 지번 주소 (표시용)
    private String x;            // 경도 (longitude) — DB: TRAVEL_ITINERARY.MAP_X
    private String y;            // 위도 (latitude)  — DB: TRAVEL_ITINERARY.MAP_Y
    private String categoryName; // category_name — 카테고리 (아이콘 결정용)
}
