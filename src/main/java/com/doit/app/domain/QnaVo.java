/*===============================================
    QnaVo.java
    - 문의 도메인 객체
    - QNA_QUESTION JOIN QNA_TYPE JOIN QNA_ANSWER 결과 매핑
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class QnaVo
{
    private Long   qnaReqNo;     // 문의 고유번호    (QNA_QUESTION.QNA_REQ_NO)
    private Long   memberNo;     // 회원 고유번호    (QNA_QUESTION.MEMBER_NO)
    private String qnaTypeCd;   // 카테고리 코드    (QNA_QUESTION.QNA_TYPE_CD)
    private String qnaTypeNm;   // 카테고리명       (QNA_TYPE.QNA_TYPE_NM) - JOIN
    private String qnaTitle;    // 문의 제목        (QNA_QUESTION.QNA_TITLE)
    private String qnaContent;  // 문의 내용        (QNA_QUESTION.QNA_CONTENT)
    private String statusCd;    // 처리상태         (QNA_QUESTION.STATUS_CD) ST001:접수, ST002:답변완료
    private String createDt;    // 문의 일시        (QNA_QUESTION.CREATE_DT)
    private String ansContent;      // 답변 내용        (QNA_ANSWER.ANS_CONTENT) - JOIN
    private String memberNickname;  // 회원 닉네임      (MEMBER_ACTIVE.NICKNAME) - 관리자 목록용
}
