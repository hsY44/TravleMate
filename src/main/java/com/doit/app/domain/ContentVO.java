package com.doit.app.domain;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ContentVO {

	private long contentId;			// 컨텐츠 ID        
	private String title;			// 제목
	private String addr1;			// 주소1
	private String addr2;			// 주소2(상세)
	private String contentTypeId;	// 컨텐츠 카테고리 ID
	private String contentDiv;		// 컨텐츠 카테고리명
	private String mapX;			// 경도
	private String mapY;			// 위도
	
	private String firstImage;		// 이미지
	private String firstImage2;		// 이미지2
	
	private int reviewCount;		// 리뷰수
	private int avgRating;			// 평점
	
	private String eventStartDate;	// 행사시작일
	private String eventEndDate;	// 행사종료일
	
	// API 관련(관리자 화면에서만 사용)
	private String createdTime;		// 생성일자
	private  String modifiedTime;	// 수정일자
	private String apiId;			// API의 CONTENTID


    // 상세 페이지 전용 필드
    private String description;		// 설명
    private String bookmark;		// 즐겨찾기 여부
//    private List<String> images;	// 이미지 목록 (firstImage + firstImage2 조합)

    // contentDetail.jsp EL 표현식 alias getter
    public Long   getId()          { return contentId; }
    public String getName()        { return title; }
    public String getAddress()     { return addr1; }
    public String getCategory()    { return contentDiv; }
    public int    getRating()      { return avgRating; }
    public String getEventPeriod() {
        if (eventStartDate == null || eventStartDate.isBlank()) return null;
        if (eventEndDate   == null || eventEndDate.isBlank())   return eventStartDate;
        return eventStartDate + " ~ " + eventEndDate;
    }
}
