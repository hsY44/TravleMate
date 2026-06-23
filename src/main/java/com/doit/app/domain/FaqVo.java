/*===============================================
    FaqVo.java
    - FAQ 도메인 객체
    - FAQ JOIN FAQ_TYPE 결과 매핑
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class FaqVo
{
    private Long   faqNo;         // FAQ 고유번호   (FAQ.FAQ_NO)
    private String faqTypeCd;     // 카테고리 코드  (FAQ.FAQ_TYPE_CD)
    private String faqTypeNm;     // 카테고리명     (FAQ_TYPE.FAQ_TYPE_NM) - JOIN
    private String faqQuestion;   // 질문 제목      (FAQ.FAQ_QUESTION)
    private String faqAnswer;     // 답변 내용      (FAQ.FAQ_ANSWER)
    private String createDt;      // 작성일         (FAQ.CREATE_DT)
}
