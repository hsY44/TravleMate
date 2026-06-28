/*===============================================
    AdminReviewMapper.java
    - 관리자 리뷰 관련 MyBatis Mapper 인터페이스
    - adminReviewMapper.xml 과 연결
===============================================*/
package com.doit.app.mapper;

import com.doit.app.domain.ReviewVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Map;

@Mapper
public interface AdminReviewMapper {

	// 리뷰 수 (검색 조건 포함)
	int selectReviewCount(Map<String, Object> map);

	// 리뷰 목록 조회 (검색 + 페이징)
	List<ReviewVo> selectReviews(Map<String, Object> map);

    // 특정 리뷰를 블라인드 처리 (BLIND_YN = 'Y')
    int updateReviewBlind(@Param("reviewNo") Long reviewNo);
}
