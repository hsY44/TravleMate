/*===============================================
    NoticeService.java
    - 사용자 공지사항 비즈니스 로직
    - NoticeMapper 를 통해 DB 연동
===============================================*/
package com.doit.app.service;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.NoticeVo;
import com.doit.app.mapper.NoticeMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@RequiredArgsConstructor
@Slf4j
@Service
public class NoticeService
{
    private final NoticeMapper noticeMapper;

    private static final int PAGE_SIZE = 10;

    // 공지사항 목록 - 페이징
    public List<NoticeVo> getNotices(int page, PaginateUtil pageInfo)
    {
        int totalCount = noticeMapper.countNotices();
        pageInfo.setTotalCount(totalCount);
        return noticeMapper.selectNotices(pageInfo.getStartRow(), pageInfo.getEndRow());
    }

    // 공지사항 상세 조회 + 조회수 증가
    public NoticeVo getNotice(Long noticeNo)
    {
        noticeMapper.updateViewCnt(noticeNo);
        return noticeMapper.selectNoticeByNo(noticeNo);
    }

    // PaginateUtil 생성
    public PaginateUtil createPageInfo(int page)
    {
        return new PaginateUtil(page, PAGE_SIZE);
    }
}
