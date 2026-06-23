/*===============================================
    ChecklistMapper.java
    - 체크리스트 MyBatis Mapper 인터페이스
    - checklistMapper.xml 과 연결
===============================================*/
package com.doit.app.mapper;

import com.doit.app.domain.ChecklistVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ChecklistMapper
{
    // 계획 체크리스트 목록 조회 (등록일 오름차순)
    List<ChecklistVo> selectChecklistItems(@Param("planNo") Long planNo) throws Exception;

    // 체크리스트 항목 추가
    void insertChecklistItem(ChecklistVo vo) throws Exception;

    // 체크리스트 항목 수정 (content / isChecked 중 전달된 것만 반영)
    int updateChecklistItem(@Param("no")          Long    no,
                            @Param("planNo")      Long    planNo,
                            @Param("content")     String  content,
                            @Param("isChecked")   Integer isChecked) throws Exception;

    // 체크리스트 항목 삭제
    int deleteChecklistItem(@Param("no")     Long no,
                            @Param("planNo") Long planNo) throws Exception;
}
