package com.doit.app.service;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.ContentCategoryVO;
import com.doit.app.domain.ContentImageVO;
import com.doit.app.domain.ContentVO;

import java.util.List;
import java.util.Map;

public interface AdminContentService {

	// 데이터 개수
	public int dataCount(Map<String, Object> map);
	
	// 컨텐츠 목록
	public List<ContentVO> listContent(Map<String, Object> map);
	
	// 컨텐츠 카테고리 조회
	public List<ContentCategoryVO> listCategory();

    // 컨텐츠 상세
    public ContentVO getContentDetail(Long contentId);

    // 컨텐츠 상세 - 컨텐츠 이미지들
    public List<ContentImageVO> getContentImages(Long contentId);

    // 페이징
	public PaginateUtil createPageInfo(int page, int page_size);
}
