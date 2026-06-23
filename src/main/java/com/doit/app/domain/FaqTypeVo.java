/*===============================================
    FaqTypeVo.java
    - FAQ 카테고리 도메인 객체
    - FAQ_TYPE 테이블 매핑
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class FaqTypeVo
{
    private String faqTypeCd;   // 카테고리 코드  (FAQ_TYPE.FAQ_TYPE_CD)
    private String faqTypeNm;   // 카테고리명     (FAQ_TYPE.FAQ_TYPE_NM)
}
