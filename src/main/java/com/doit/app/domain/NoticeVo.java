/*===============================================
    NoticeVo.java
    - 공지사항 도메인 객체
    - NOTICE 테이블 매핑
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class NoticeVo
{
    private Long   noticeNo;       // 공지사항 고유번호  (NOTICE.NOTICE_NO)
    private Long   adminNo;        // 작성 관리자 번호   (NOTICE.ADMIN_NO)
    private String noticeTitle;    // 제목               (NOTICE.NOTICE_TITLE)
    private String noticeContent;  // 내용               (NOTICE.NOTICE_CONTENT)
    private int    viewCnt;        // 조회수             (NOTICE.VIEW_CNT)
    private String createDt;       // 작성일             (NOTICE.CREATE_DT)
}
