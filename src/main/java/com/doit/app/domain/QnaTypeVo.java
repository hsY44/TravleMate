/*===============================================
    QnaTypeVo.java
    - 문의 카테고리 도메인 객체
    - QNA_TYPE 테이블 매핑
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class QnaTypeVo
{
    private String qnaTypeCd;   // 카테고리 코드  (QNA_TYPE.QNA_TYPE_CD)
    private String qnaTypeNm;   // 카테고리명     (QNA_TYPE.QNA_TYPE_NM)
}
