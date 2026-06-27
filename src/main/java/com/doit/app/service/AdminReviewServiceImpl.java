package com.doit.app.service;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.ReviewVo;
import com.doit.app.mapper.AdminReviewMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class AdminReviewServiceImpl implements AdminReviewService {

	private final AdminReviewMapper mapper;
	
	// 리뷰 개수 조회
	@Override
	public int getReviewCount(Map<String, Object> map) {
		int result = 0;
		
		try {
			result = mapper.selectReviewCount(map);
		} catch (Exception e) {
			log.error("getReviewCount : ", e);
		}
		
		return result;
	}
	
	// 컨텐츠 리뷰 조회
	@Override
	public List<ReviewVo> listContentReview(Map<String, Object> map) {

		List<ReviewVo> list = null;
		
		try {
			list = mapper.selectReviews(map);
		} catch (Exception e) {
			log.error("listContentReview : ", e);
		}
		
		return list;
	}

    @Override
    public int updateReviewBlind(Long reviewNo) {
        int result = 0;
        try {
            result = mapper.updateReviewBlind(reviewNo);
        } catch (Exception e) {
            log.error("updateReviewBlind : ", e);
        }
        return result;
    }

    @Override
    public PaginateUtil createPageInfo(int page, int page_size)
    {
        return new PaginateUtil(page, page_size);
    }
}
