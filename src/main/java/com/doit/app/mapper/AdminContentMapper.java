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
    public int dataCount(Map<String, Object> map);

    // 컨텐츠 목록
    public List<ContentVO> listContent(Map<String, Object> map);

    // 컨텐츠 카테고리 조회
    public List<ContentCategoryVO> listCategory();

    // 컨텐츠 상세
    ContentVO selectContentDetail(@Param("contentId") Long contentId);

    // 컨텐츠 상세 - 컨텐츠 이미지들
    public List<ContentImageVO> selectContentImages(Long contentId);

}
