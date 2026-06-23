/*===============================================
    QnaService.java
    - 문의 관련 비즈니스 로직
    - QnaMapper 를 통해 DB 연동
===============================================*/
package com.doit.app.service;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.QnaTypeVo;
import com.doit.app.domain.QnaVo;
import com.doit.app.mapper.QnaMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@RequiredArgsConstructor
@Slf4j
@Service
public class QnaService
{
    private final QnaMapper qnaMapper;

    private static final int PAGE_SIZE = 10;

    // 문의 카테고리 전체 조회
    public List<QnaTypeVo> getQnaTypes()
    {
        return qnaMapper.selectQnaTypes();
    }

    // 문의 등록
    // memberNo 는 Controller 에서 세션으로 설정 후 전달
    public void submitQuestion(QnaVo qnaVo)
    {
        qnaMapper.insertQnaQuestion(qnaVo);
    }

    // 회원별 문의 목록 조회 - 페이징 (독립 목록 페이지)
    // PaginateUtil 에 totalCount 를 채워 반환 (JSP 페이지 버튼 렌더링에 사용)
    public List<QnaVo> getQnasByMemberNo(Long memberNo, int page, PaginateUtil pageInfo)
    {
        int totalCount = qnaMapper.countQnasByMemberNo(memberNo);
        pageInfo.setTotalCount(totalCount);
        return qnaMapper.selectQnasByMemberNo(memberNo, pageInfo.getStartRow(), pageInfo.getEndRow());
    }

    // 마이페이지 탭용 최근 문의 5건
    public List<QnaVo> getRecentQnasByMemberNo(Long memberNo)
    {
        return qnaMapper.selectRecentQnasByMemberNo(memberNo);
    }

    // 문의 단건 조회 - 본인 문의만
    public QnaVo getQnaDetail(Long qnaReqNo, Long memberNo)
    {
        return qnaMapper.selectQnaDetail(qnaReqNo, memberNo);
    }

    // PaginateUtil 생성 팩토리 (Controller 에서 편하게 호출)
    public PaginateUtil createPageInfo(int page)
    {
        return new PaginateUtil(page, PAGE_SIZE);
    }
}
