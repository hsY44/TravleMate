/*===============================================
    ChecklistService.java
    - 체크리스트(준비물) 비즈니스 로직
    - ChecklistMapper 를 통해 DB 연동
===============================================*/
package com.doit.app.service;

import com.doit.app.domain.ChecklistVo;
import com.doit.app.mapper.ChecklistMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ChecklistService
{
    private final ChecklistMapper checklistMapper;

    // 계획 체크리스트 목록 조회
    public List<ChecklistVo> getChecklistItems(Long planNo)
    {
        List<ChecklistVo> list = null;
        try {
            list = checklistMapper.selectChecklistItems(planNo);
        } catch (Exception e) {
            log.error("getChecklistItems : ", e);
        }
        return list;
    }

    // 체크리스트 항목 추가
    public void addChecklistItem(Long planNo, String content)
    {
        try {
            ChecklistVo vo = new ChecklistVo();
            vo.setPlanNo(planNo);
            vo.setContent(content);
            checklistMapper.insertChecklistItem(vo);
        } catch (Exception e) {
            log.error("addChecklistItem : ", e);
        }
    }

    // 체크리스트 항목 수정 - content / isChecked 중 전달된 것만 UPDATE
    public boolean updateChecklistItem(Long no, Long planNo, String content, Integer isChecked)
    {
        int result = 0;
        try {
            result = checklistMapper.updateChecklistItem(no, planNo, content, isChecked);
        } catch (Exception e) {
            log.error("updateChecklistItem : ", e);
        }
        return result > 0;
    }

    // 체크리스트 항목 삭제
    public boolean removeChecklistItem(Long no, Long planNo)
    {
        int result = 0;
        try {
            result = checklistMapper.deleteChecklistItem(no, planNo);
        } catch (Exception e) {
            log.error("removeChecklistItem : ", e);
        }
        return result > 0;
    }
}
