/*===============================================
    BookmarkVo.java
    - 즐겨찾기 도메인 객체
    - MEMBER_BOOKMARK JOIN CONTENT JOIN CONTENTCATEGORY 결과 매핑
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class BookmarkVo
{
    private Long   bookmarkNo;   // 즐겨찾기 고유번호  (MEMBER_BOOKMARK.BOOKMARK_NO)
    private Long   memberNo;     // 회원 고유번호      (MEMBER_BOOKMARK.MEMBER_NO)
    private Long   contentId;    // 컨텐츠 고유번호    (MEMBER_BOOKMARK.CONTENTID)
    private String title;        // 컨텐츠명           (CONTENT.TITLE)
    private String addr1;        // 주소               (CONTENT.ADDR1)
    private String contentDiv;   // 컨텐츠구분명       (CONTENTCATEGORY.CONTENTDIV)
    private String createDt;     // 즐겨찾기 등록일    (MEMBER_BOOKMARK.CREATE_DT)
}
