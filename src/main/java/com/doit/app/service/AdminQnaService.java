/*===============================================
    AdminQnaService.java
    - 관리자 문의 관리 비즈니스 로직
    - AdminQnaMapper 를 통해 DB 연동
===============================================*/
package com.doit.app.service;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.QnaTypeVo;
import com.doit.app.domain.QnaVo;
import com.doit.app.mapper.AdminQnaMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@RequiredArgsConstructor
@Slf4j
@Service
public class AdminQnaService
{
    private final AdminQnaMapper adminQnaMapper;

    private static final int PAGE_SIZE = 15;

    // 문의 카테고리 전체 조회
    public List<QnaTypeVo> getQnaTypes()
    {
        return adminQnaMapper.selectQnaTypes();
    }

    // 문의 카테고리 등록
    public int addQnaType(QnaTypeVo vo)
    {
        return adminQnaMapper.insertQnaType(vo);
    }

    // 문의 카테고리 수정
    public int editQnaType(QnaTypeVo vo)
    {
        return adminQnaMapper.updateQnaType(vo);
    }

    // 전체 문의 목록 - 페이징
    public List<QnaVo> getAllQnas(int page, PaginateUtil pageInfo)
    {
        int totalCount = adminQnaMapper.countAllQnas();
        pageInfo.setTotalCount(totalCount);
        return adminQnaMapper.selectAllQnas(pageInfo.getStartRow(), pageInfo.getEndRow());
    }

    // 문의 단건 조회 (관리자용)
    public QnaVo getQnaDetail(Long qnaReqNo)
    {
        return adminQnaMapper.selectQnaDetailForAdmin(qnaReqNo);
    }

    // 답변 등록 + 상태 ST002 변경 (트랜잭션)
    @Transactional
    public void submitAnswer(Long qnaReqNo, Long adminNo, String ansContent)
    {
        adminQnaMapper.insertQnaAnswer(qnaReqNo, adminNo, ansContent);
        adminQnaMapper.updateQnaStatus(qnaReqNo);
    }

    public PaginateUtil createPageInfo(int page)
    {
        return new PaginateUtil(page, PAGE_SIZE);
    }
}
