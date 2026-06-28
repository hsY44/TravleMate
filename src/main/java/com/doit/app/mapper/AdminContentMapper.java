/*===============================================
    AdminContentMapper.java
    - 관리자 컨텐츠 관련 MyBatis Mapper 인터페이스
    - adminContentMapper.xml 과 연결
===============================================*/
package com.doit.app.mapper;

import com.doit.app.domain.ContentCategoryVO;
import com.doit.app.domain.ContentImageVO;
import com.doit.app.domain.ContentVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface AdminContentMapper {
    // 데이터 개수
    int dataCount(Map<String, Object> map);

    // 컨텐츠 목록
    List<ContentVO> listContent(Map<String, Object> map);

    // 컨텐츠 카테고리 조회
    List<ContentCategoryVO> listCategory();

    // 컨텐츠 상세
    ContentVO selectContentDetail(@Param("contentId") Long contentId);

    // 컨텐츠 상세 - 컨텐츠 이미지들
    List<ContentImageVO> selectContentImages(Long contentId);
}
