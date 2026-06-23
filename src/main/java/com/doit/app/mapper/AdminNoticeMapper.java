/*===============================================
    AdminNoticeMapper.java
    - 관리자 공지사항 관리 MyBatis Mapper 인터페이스
    - adminNoticeMapper.xml 과 연결
===============================================*/
package com.doit.app.mapper;

import com.doit.app.domain.NoticeVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface AdminNoticeMapper
{
    // 공지사항 수 (페이징용)
    int countAdminNotices();

    // 공지사항 단건 조회 (수정용)
    NoticeVo selectAdminNoticeByNo(Long noticeNo);

    // 공지사항 목록 - 페이징
    List<NoticeVo> selectAdminNotices(@Param("startRow") int startRow,
                                       @Param("endRow")   int endRow);

    // 공지사항 등록
    int insertNotice(@Param("adminNo")       Long   adminNo,
                     @Param("noticeTitle")   String noticeTitle,
                     @Param("noticeContent") String noticeContent);

    // 공지사항 수정
    int updateNotice(@Param("noticeNo")      Long   noticeNo,
                     @Param("noticeTitle")   String noticeTitle,
                     @Param("noticeContent") String noticeContent);

    // 공지사항 삭제
    int deleteNotice(Long noticeNo);
}
