/*===============================================
    QnaMapper.java
    - 문의 관련 MyBatis Mapper 인터페이스
    - qnaMapper.xml 과 연결
===============================================*/
package com.doit.app.mapper;

import com.doit.app.domain.QnaTypeVo;
import com.doit.app.domain.QnaVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface QnaMapper
{
    // 문의 카테고리 전체 조회
    List<QnaTypeVo> selectQnaTypes();

    // 문의 등록 (QNA_QUESTION INSERT)
    int insertQnaQuestion(QnaVo qnaVo);

    // 회원별 문의 전체 건수 (페이징 계산용)
    int countQnasByMemberNo(Long memberNo);

    // 회원별 문의 목록 조회 - 페이징 (독립 목록 페이지)
    List<QnaVo> selectQnasByMemberNo(@Param("memberNo") Long memberNo,
                                     @Param("startRow") int startRow,
                                     @Param("endRow")   int endRow);

    // 회원별 최근 문의 5건 (마이페이지 탭)
    List<QnaVo> selectRecentQnasByMemberNo(Long memberNo);

    // 문의 단건 조회 - 본인 문의만 (memberNo 검증)
    QnaVo selectQnaDetail(@Param("qnaReqNo") Long qnaReqNo,
                          @Param("memberNo") Long memberNo);
}
