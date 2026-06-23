/*===============================================
    AdminQnaMapper.java
    - 관리자 문의 관리 MyBatis Mapper 인터페이스
    - adminQnaMapper.xml 과 연결
===============================================*/
package com.doit.app.mapper;

import com.doit.app.domain.QnaTypeVo;
import com.doit.app.domain.QnaVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface AdminQnaMapper
{
    // 문의 카테고리

    // 문의 카테고리 전체 조회
    List<QnaTypeVo> selectQnaTypes();

    // 문의 카테고리 등록
    int insertQnaType(QnaTypeVo vo);

    // 문의 카테고리 수정
    int updateQnaType(QnaTypeVo vo);

    // 문의 목록 / 상세 

    // 전체 문의 수 (페이징용)
    int countAllQnas();

    // 전체 문의 목록 - 페이징
    List<QnaVo> selectAllQnas(@Param("startRow") int startRow,
                               @Param("endRow")   int endRow);

    // 문의 단건 조회 (관리자용 - memberNo 조건 없음)
    QnaVo selectQnaDetailForAdmin(Long qnaReqNo);

    // 답변

    // 답변 등록
    int insertQnaAnswer(@Param("qnaReqNo")   Long   qnaReqNo,
                        @Param("adminNo")    Long   adminNo,
                        @Param("ansContent") String ansContent);

    // 문의 상태 변경 (ST001 → ST002)
    int updateQnaStatus(Long qnaReqNo);
}
