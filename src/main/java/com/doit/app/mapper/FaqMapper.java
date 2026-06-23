/*===============================================
    FaqMapper.java
    - FAQ 관련 MyBatis Mapper 인터페이스
    - faqMapper.xml 과 연결
===============================================*/
package com.doit.app.mapper;

import com.doit.app.domain.FaqTypeVo;
import com.doit.app.domain.FaqVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface FaqMapper
{
    // FAQ 카테고리 전체 조회 (카테고리 탭 렌더링용)
    List<FaqTypeVo> selectFaqTypes();

    // FAQ 목록 전체 조회 - FAQ_TYPE JOIN, 카테고리/등록순 정렬
    List<FaqVo> selectFaqs(@Param("faqTypeCd") String faqTypeCd);
}
