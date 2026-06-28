/*===============================================
    ContentMapper.java
    - 컨텐츠 관련 MyBatis Mapper 인터페이스
    - contentMapper.xml 과 연결
===============================================*/
package com.doit.app.mapper;

import java.util.List;
import java.util.Map;

import com.doit.app.domain.ContentImageVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.doit.app.domain.ContentCategoryVO;
import com.doit.app.domain.ContentVO;

@Mapper
public interface ContentMapper {

	// 데이터 개수
	int dataCount(Map<String, Object> map);

	// 컨텐츠 목록
	List<ContentVO> listContent(Map<String, Object> map);

	// 컨텐츠 카테고리 조회
	List<ContentCategoryVO> listCategory();

    // 컨텐츠 상세
	ContentVO selectContentDetail(@Param("contentId") Long contentId,
	                              @Param("memberNo")  Long memberNo);

    // 컨텐츠 상세 - 컨텐츠 이미지들
    List<ContentImageVO> selectContentImages(Long contentId);

	// -- 즐겨찾기 ---------------------------------
	int countBookmark(@Param("memberNo")  Long memberNo,
	                  @Param("contentId") Long contentId);

	void insertBookmark(@Param("memberNo")  Long memberNo,
	                    @Param("contentId") Long contentId);

	void deleteBookmark(@Param("memberNo")  Long memberNo,
	                    @Param("contentId") Long contentId);
}
