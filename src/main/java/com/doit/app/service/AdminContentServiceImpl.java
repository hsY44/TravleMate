package com.doit.app.service;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.ContentCategoryVO;
import com.doit.app.domain.ContentImageVO;
import com.doit.app.domain.ContentVO;
import com.doit.app.mapper.AdminContentMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class AdminContentServiceImpl implements AdminContentService {

	private final AdminContentMapper mapper;

    /**
     * 컨텐츠 데이터 개수
     * @param map category, kwd
     * @return int 컨텐츠 갯수
     */
	@Override
	public int dataCount(Map<String, Object> map) {
		int result = 0;

        try {
            result = mapper.dataCount(map);
        } catch (Exception e) {
            log.info("dataCount : ", e);
        }

		return result;
	}

    /**
     * 컨텐츠 목록
     * @param map category, kwd, memberNo, offset, size
     * @return List<ContentVO> 컨텐츠 목록
     */
	@Override
	public List<ContentVO> listContent(Map<String, Object> map) {
		
		List<ContentVO> list = null;
		
		try {
			list = mapper.listContent(map);
		} catch (Exception e) {
			log.info("listContent : ", e);
		}
		
		return list;
	}

    /**
     * 컨텐츠 카테고리
     * @return List<ContentCategoryVO> 컨텐츠 카테고리
     */
	@Override
	public List<ContentCategoryVO> listCategory() {
		
		List<ContentCategoryVO> list = null;
		
		try {
			list = mapper.listCategory();
		} catch (Exception e) {
			log.info("listCategory : ", e);
		}
		
		return list;
	}

    //

    /**
     * 컨텐츠 상세
     * @param contentId 컨텐츠ID
     * @return ContentVO 컨텐츠 상세
     */
    @Override
    public ContentVO getContentDetail(Long contentId) {

        ContentVO content = null;

        try {
            content = mapper.selectContentDetail(contentId);
        } catch (Exception e) {
            log.info("contentDetail : ", e);
        }

        return content;
    }

    /**
     * 컨텐츠 상세 - 컨텐츠 이미지들
     * @param contentId 컨텐츠 ID
     * @return List<ContentImageVO> 컨텐츠 이미지들
     */
    public List<ContentImageVO> getContentImages(Long contentId) {
        List<ContentImageVO> images = null;

        try {
            images = mapper.selectContentImages(contentId);
        } catch (Exception e) {
            log.info("getContentImages : ", e);
        }
        return images;
    }

    @Override
    public PaginateUtil createPageInfo(int page, int page_size)
    {
        return new PaginateUtil(page, page_size);
    }

}
