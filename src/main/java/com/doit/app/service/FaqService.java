/*===============================================
    FaqService.java
    - FAQ 비즈니스 로직
    - FaqMapper 를 통해 DB 연동
===============================================*/
package com.doit.app.service;

import com.doit.app.domain.FaqTypeVo;
import com.doit.app.domain.FaqVo;
import com.doit.app.mapper.FaqMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@RequiredArgsConstructor
@Slf4j
@Service
public class FaqService
{
    private final FaqMapper faqMapper;

    // FAQ 카테고리 전체 조회
    public List<FaqTypeVo> getFaqTypes()
    {
        return faqMapper.selectFaqTypes();
    }

    // FAQ 목록 조회 - faqTypeCd null/빈 값이면 전체
    public List<FaqVo> getFaqs(String faqTypeCd)
    {
        return faqMapper.selectFaqs(faqTypeCd);
    }
}
