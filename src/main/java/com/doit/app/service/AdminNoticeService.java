/*===============================================
    AdminNoticeService.java
    - 관리자 공지사항 관리 비즈니스 로직
    - AdminNoticeMapper 를 통해 DB 연동
===============================================*/
package com.doit.app.service;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.NoticeVo;
import com.doit.app.mapper.AdminNoticeMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@RequiredArgsConstructor
@Slf4j
@Service
public class AdminNoticeService
{
    private final AdminNoticeMapper adminNoticeMapper;

    private static final int PAGE_SIZE = 10;

    // 공지사항 목록 - 페이징
    public List<NoticeVo> getNotices(int page, PaginateUtil pageInfo)
    {
        int totalCount = adminNoticeMapper.countAdminNotices();
        pageInfo.setTotalCount(totalCount);
        return adminNoticeMapper.selectAdminNotices(pageInfo.getStartRow(), pageInfo.getEndRow());
    }

    // 공지사항 단건 조회 (수정 모달 pre-fill용)
    public NoticeVo getNotice(Long noticeNo)
    {
        return adminNoticeMapper.selectAdminNoticeByNo(noticeNo);
    }

    // 공지사항 등록
    public int addNotice(Long adminNo, String noticeTitle, String noticeContent)
    {
        return adminNoticeMapper.insertNotice(adminNo, noticeTitle, noticeContent);
    }

    // 공지사항 수정
    public int editNotice(Long noticeNo, String noticeTitle, String noticeContent)
    {
        return adminNoticeMapper.updateNotice(noticeNo, noticeTitle, noticeContent);
    }

    // 공지사항 삭제
    public int removeNotice(Long noticeNo)
    {
        return adminNoticeMapper.deleteNotice(noticeNo);
    }

    public PaginateUtil createPageInfo(int page)
    {
        return new PaginateUtil(page, PAGE_SIZE);
    }
}
