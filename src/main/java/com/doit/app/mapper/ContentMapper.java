package com.doit.app.mapper;

import java.util.List;
import java.util.Map;

import com.doit.app.domain.ContentImageVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.doit.app.domain.ContentCategoryVO;
import com.doit.app.domain.ContentVO;
import com.doit.app.domain.ReviewVo;

@Mapper
public interface ContentMapper {

	// 데이터 개수
	public int dataCount(Map<String, Object> map);

	// 컨텐츠 목록
	public List<ContentVO> listContent(Map<String, Object> map);

	// 컨텐츠 카테고리 조회
	public List<ContentCategoryVO> listCategory();

    // 컨텐츠 상세
	ContentVO selectContentDetail(@Param("contentId") Long contentId,
	                              @Param("memberNo")  Long memberNo);

    // 컨텐츠 상세 - 컨텐츠 이미지들
    public List<ContentImageVO> selectContentImages(Long contentId);

	// -- 즐겨찾기 ---------------------------------
	int countBookmark(@Param("memberNo")  Long memberNo,
	                  @Param("contentId") Long contentId);

	void insertBookmark(@Param("memberNo")  Long memberNo,
	                    @Param("contentId") Long contentId);

	void deleteBookmark(@Param("memberNo")  Long memberNo,
	                    @Param("contentId") Long contentId);
}
