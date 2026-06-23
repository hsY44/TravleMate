/*===============================================
    AdminFaqMapper.java
    - 관리자 FAQ 관리 MyBatis Mapper 인터페이스
    - adminFaqMapper.xml 과 연결
===============================================*/
package com.doit.app.mapper;

import com.doit.app.domain.FaqTypeVo;
import com.doit.app.domain.FaqVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface AdminFaqMapper
{
    // FAQ 카테고리 

    // FAQ 카테고리 전체 조회
    List<FaqTypeVo> selectFaqTypes();

    // FAQ 카테고리 등록
    int insertFaqType(FaqTypeVo vo);

    // FAQ 카테고리 이름 수정
    int updateFaqType(FaqTypeVo vo);

    // FAQ CRUD

    // FAQ 전체 목록 (관리자용 - 등록일 역순)
    List<FaqVo> selectAllFaqs();

    // FAQ 단건 조회
    FaqVo selectFaqByNo(Long faqNo);

    // FAQ 등록
    int insertFaq(@Param("adminNo")     Long   adminNo,
                  @Param("faqTypeCd")   String faqTypeCd,
                  @Param("faqQuestion") String faqQuestion,
                  @Param("faqAnswer")   String faqAnswer);

    // FAQ 수정
    int updateFaq(@Param("faqNo")       Long   faqNo,
                  @Param("faqTypeCd")   String faqTypeCd,
                  @Param("faqQuestion") String faqQuestion,
                  @Param("faqAnswer")   String faqAnswer);

    // FAQ 삭제
    int deleteFaq(Long faqNo);
}
