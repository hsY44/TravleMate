/*===============================================
    ReviewVo.java
    - 리뷰 도메인 객체
    - CONTENT_REVIEW JOIN CONTENT 결과 매핑
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class ReviewVo
{
    private Long   contentReviewNo;  // 리뷰 고유번호    (CONTENT_REVIEW.CONTENT_REVIEW_NO)
    private Long   memberNo;         // 회원 고유번호    (CONTENT_REVIEW.MEMBER_NO)
    private Long   contentId;        // 컨텐츠 고유번호  (CONTENT_REVIEW.CONTENTID)
    private String title;            // 컨텐츠명         (CONTENT.TITLE)
    private String nickname;         // 작성자 닉네임    (MEMBER_ACTIVE.NICKNAME)
    private String reviewComment;    // 리뷰 내용        (CONTENT_REVIEW.REVIEW_COMMENT)
    private int    rating;           // 별점 1~5         (CONTENT_REVIEW.RATING)
    private String createDt;         // 작성일           (CONTENT_REVIEW.CREATE_DT)
    private String blindYn ;         // 블라인드 여부      (CONTENT_REVIEW.BLIND_YN)

    // contentDetail.jsp EL 표현식 alias getter
    public Long   getId()        { return contentReviewNo; }
    public String getContent()   { return reviewComment; }
    public String getCreatedAt() { return createDt; }
    public Long   getMemberId()  { return memberNo; }
}
