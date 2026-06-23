/*===============================================
    NoticeMapper.java
    - 공지사항 관련 MyBatis Mapper 인터페이스
    - noticeMapper.xml 과 연결
===============================================*/
package com.doit.app.mapper;

import com.doit.app.domain.NoticeVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface NoticeMapper
{
    // 공지사항 전체 건수 (페이징 계산용)
    int countNotices();

    // 공지사항 목록 조회 - 페이징
    List<NoticeVo> selectNotices(@Param("startRow") int startRow,
                                 @Param("endRow")   int endRow);

    // 공지사항 단건 조회
    NoticeVo selectNoticeByNo(Long noticeNo);

    // 조회수 증가 (상세 조회 시 호출)
    int updateViewCnt(Long noticeNo);
}
