/*===============================================
    AdminFaqService.java
    - 관리자 FAQ 관리 비즈니스 로직
    - AdminFaqMapper 를 통해 DB 연동
===============================================*/
package com.doit.app.service;

import com.doit.app.domain.FaqTypeVo;
import com.doit.app.domain.FaqVo;
import com.doit.app.mapper.AdminFaqMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@RequiredArgsConstructor
@Slf4j
@Service
public class AdminFaqService
{
    private final AdminFaqMapper adminFaqMapper;

    // 카테고리 

    public List<FaqTypeVo> getFaqTypes()
    {
        return adminFaqMapper.selectFaqTypes();
    }

    public int addFaqType(FaqTypeVo vo)
    {
        return adminFaqMapper.insertFaqType(vo);
    }

    public int editFaqType(FaqTypeVo vo)
    {
        return adminFaqMapper.updateFaqType(vo);
    }

    // FAQ CRUD 

    public List<FaqVo> getAllFaqs()
    {
        return adminFaqMapper.selectAllFaqs();
    }

    public int addFaq(Long adminNo, String faqTypeCd, String faqQuestion, String faqAnswer)
    {
        return adminFaqMapper.insertFaq(adminNo, faqTypeCd, faqQuestion, faqAnswer);
    }

    public int editFaq(Long faqNo, String faqTypeCd, String faqQuestion, String faqAnswer)
    {
        return adminFaqMapper.updateFaq(faqNo, faqTypeCd, faqQuestion, faqAnswer);
    }

    public int removeFaq(Long faqNo)
    {
        return adminFaqMapper.deleteFaq(faqNo);
    }
}
