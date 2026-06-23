/*===============================================
    AdminMemberService.java
    - 관리자용 회원 관리 비즈니스 로직
    - AdminMapper 를 통해 DB 연동
===============================================*/
package com.doit.app.service;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.AdminMemberVo;
import com.doit.app.domain.SanctionVo;
import com.doit.app.mapper.AdminMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@RequiredArgsConstructor
@Slf4j
@Service
public class AdminMemberService
{
    private final AdminMapper adminMapper;

    private static final int PAGE_SIZE = 15;

    // 활동 회원 목록 - 키워드 검색 + 페이징
    public List<AdminMemberVo> getActiveMembers(int page, String keyword, PaginateUtil pageInfo)
    {
        int totalCount = adminMapper.countActiveMembers(keyword);
        pageInfo.setTotalCount(totalCount);
        return adminMapper.selectActiveMembers(keyword, pageInfo.getStartRow(), pageInfo.getEndRow());
    }

    // 활동 회원 단건
    public AdminMemberVo getActiveMember(Long memberNo)
    {
        return adminMapper.selectActiveMemberByNo(memberNo);
    }

    // 탈퇴 회원 목록 - 페이징
    public List<AdminMemberVo> getLeaveMembers(int page, PaginateUtil pageInfo)
    {
        int totalCount = adminMapper.countLeaveMembers();
        pageInfo.setTotalCount(totalCount);
        return adminMapper.selectLeaveMembers(pageInfo.getStartRow(), pageInfo.getEndRow());
    }

    // 탈퇴 회원 단건
    public AdminMemberVo getLeaveMember(Long memberNo)
    {
        return adminMapper.selectLeaveMemberByNo(memberNo);
    }

    public PaginateUtil createPageInfo(int page)
    {
        return new PaginateUtil(page, PAGE_SIZE);
    }

    // 회원 제재 이력 저장
    public void sanctionMember(Long memberNo, int levelDays, String reason, String comment, Long adminNo)
    {
        SanctionVo vo = new SanctionVo();
        vo.setMemberNo(memberNo);
        vo.setLevelDays(levelDays);
        vo.setReason(reason);
        vo.setComment(comment != null ? comment : "");
        vo.setAdminNo(adminNo);
        adminMapper.insertSanction(vo);
    }
}
