package com.doit.app.mapper;

import com.doit.app.domain.ReviewVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface AdminReviewMapper {

	// 데이터 개수
	public int selectReviewCount(Map<String, Object> map);
	
	// 컨텐츠 리뷰 조회
	public List<ReviewVo> selectReviews(Map<String, Object> map);

    // 특정 리뷰를 블라인드 처리 (BLIND_YN = 'Y')
    int updateReviewBlind(@Param("reviewNo") Long reviewNo);

}
