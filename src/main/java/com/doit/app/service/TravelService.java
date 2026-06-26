/*===============================================
    TravelService.java
    - 여행 계획 관련 비즈니스 로직
    - TravelMapper 를 통해 DB 연동
===============================================*/
package com.doit.app.service;

import com.doit.app.domain.GuestVo;
import com.doit.app.domain.InvitationVo;
import com.doit.app.domain.PlanVo;
import com.doit.app.domain.TravelVo;
import com.doit.app.mapper.TravelMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class TravelService
{
    private final TravelMapper travelMapper;

    /* ----------------------------------------
       계획 조회
    ---------------------------------------- */

    // 회원별 여행계획 목록 조회
    public List<TravelVo> getPlansByMemberNo(Long memberNo)
    {
        return travelMapper.selectPlansByMemberNo(memberNo);
    }

    public PlanVo getPlanDetail(Long planNo)
    {
        return travelMapper.selectPlanDetail(planNo);
    }

    public List<PlanVo> getMyPlans(Long memberNo, String theme, String startDate, String endDate)
    {
        return travelMapper.selectMyPlans(memberNo, theme, startDate, endDate);
    }

    public List<PlanVo> getJoinedPlans(Long memberNo, String theme, String startDate, String endDate)
    {
        return travelMapper.selectJoinedPlans(memberNo, theme, startDate, endDate);
    }

    public List<String> getThemeNames()
    {
        return travelMapper.selectThemeNames();
    }

    public int countHostPlans(Long memberNo)
    {
        return travelMapper.countHostPlans(memberNo);
    }

    public int checkDateOverlap(Long memberNo, String startDt, String endDt, Long excludePlanNo)
    {
        return travelMapper.checkDateOverlap(memberNo, startDt, endDt, excludePlanNo);
    }

    public Long getPlanNoByInviteCode(String inviteCode)
    {
        return travelMapper.selectPlanNoByInviteCode(inviteCode);
    }

    public int planGuestExists(Long planNo, Long memberNo)
    {
        return travelMapper.selectPlanGuestExists(planNo, memberNo);
    }

    public int countActiveGuests(Long planNo)
    {
        return travelMapper.countActiveGuests(planNo);
    }

    public int updatePlanVisibility(Long planNo, Long hostMemberNo, int isPublic)
    {
        return travelMapper.updatePlanVisibility(planNo, hostMemberNo, isPublic);
    }

    public int updateGuestPermission(Long planNo, Long memberNo, int canEdit)
    {
        return travelMapper.updateGuestPermission(planNo, memberNo, canEdit);
    }

    /* ----------------------------------------
       계획 생성 / 수정 / 삭제
    ---------------------------------------- */

    /**
     * 새 여행 계획 생성
     * 1. TRAVEL_PLAN INSERT
     * 2. 호스트를 PLAN_GUEST 에 등록
     * 3. UUID 16자리 초대코드 생성 후 TRAVEL_INVITATION INSERT
     *
     * @return 생성된 planNo
     */
    @Transactional
    public Long createPlan(PlanVo planVo, Long memberNo)
    {
        planVo.setHostMemberNo(memberNo);
        travelMapper.insertPlan(planVo);                  // planVo.id 에 PK 반영

        travelMapper.insertPlanGuest(planVo.getId(), memberNo);

        String inviteCode = UUID.randomUUID()
                               .toString()
                               .replace("-", "")
                               .substring(0, 16)
                               .toUpperCase();
        travelMapper.insertInvitation(planVo.getId(), inviteCode);

        return planVo.getId();
    }

    /* ----------------------------------------
       게스트 관리
    ---------------------------------------- */

    /** 게스트 목록 조회 (탈퇴/내보내기된 게스트 제외) */
    public List<GuestVo> getGuests(Long planNo)
    {
        return travelMapper.selectGuests(planNo);
    }

    /**
     * 초대코드로 계획 참여
     * @return 참여한(또는 이미 참여 중인) planNo, 코드가 없으면 null
     */
    @Transactional
    public Long joinByInviteCode(String inviteCode, Long memberNo)
    {
        Long planNo = travelMapper.selectPlanNoByInviteCode(inviteCode);
        if (planNo == null) {
            return null;
        }
        if (travelMapper.selectPlanGuestExists(planNo, memberNo) == 0) {
            travelMapper.insertPlanGuest(planNo, memberNo);
        }
        return planNo;
    }

    /**
     * 게스트 내보내기 (호스트 전용)
     * - PLAN_GUEST_LEAVE 에 내보내기 이력 기록 (GST_LEV002)
     * - PLAN_GUEST 는 삭제하지 않음 (소프트 삭제 방식)
     *   PLAN_GUEST_LEAVE.PLAN_GUEST_NO 가 PLAN_GUEST 를 FK 참조하므로
     *   PLAN_GUEST 삭제 시 ORA-02292 발생 → PLAN_GUEST 유지, LEAVE 기록으로 비활성화
     * - selectGuests 에서 PLAN_GUEST_LEAVE 없는 게스트만 조회하므로 UI 에서 제거됨
     */
    @Transactional
    public void kickGuest(Long planNo, Long memberNo)
    {
        Long planGuestNo = travelMapper.selectPlanGuestNoByMember(planNo, memberNo);
        if (planGuestNo == null) return;
        travelMapper.insertPlanGuestLeave(planGuestNo, "GST_LEV002");
    }

    /** 계획 수정 (호스트만) */
    public void updatePlan(PlanVo planVo)
    {
        travelMapper.updatePlan(planVo);
    }

    /**
     * 호스트 위임 - TRAVEL_PLAN.HOST_MEMBER_NO 갱신
     * 현재 호스트 세션과 DB WHERE 조건 일치 시에만 성공
     */
    @Transactional
    public boolean transferHost(Long planNo, Long newHostMemberNo, Long currentHostMemberNo)
    {
        int rows = travelMapper.updatePlanHost(planNo, newHostMemberNo, currentHostMemberNo);
        return rows > 0;
    }

    /**
     * 초대코드 재생성 - 새 UUID 16자리 코드 생성 후 TRAVEL_INVITATION INSERT
     */
    @Transactional
    public String regenerateInviteCode(Long planNo)
    {
        String code = UUID.randomUUID()
                          .toString()
                          .replace("-", "")
                          .substring(0, 16)
                          .toUpperCase();
        travelMapper.deleteInviteCodeByPlanNo(planNo);
        travelMapper.insertInvitation(planNo, code);
        return code;
    }

    /**
     * 계획 나가기 (게스트 본인, 자진 탈퇴)
     * - PLAN_GUEST_LEAVE 에 GST_LEV001(자진탈퇴) 이력 기록
     * @return 성공 여부 (참여자가 아니면 false)
     */
    @Transactional
    public boolean leavePlan(Long planNo, Long memberNo)
    {
        Long planGuestNo = travelMapper.selectPlanGuestNoByMember(planNo, memberNo);
        if (planGuestNo == null) return false;
        travelMapper.insertPlanGuestLeave(planGuestNo, "GST_LEV001");
        return true;
    }

    /* ----------------------------------------
       탈퇴 처리 보조
    ---------------------------------------- */

    /**
     * 탈퇴 전 호스트 계획 처리 - MemberController.withdraw 에서 memberService.withdraw 전에 호출
     * - 활성 게스트 있음 → CREATE_DT 오름차순 첫 번째 게스트에게 호스트 위임
     * - 활성 게스트 없음 → FK 순서대로 계획 완전 삭제
     */
    @Transactional
    public void handleWithdrawal(Long memberNo)
    {
        List<Long> hostPlanNos = travelMapper.selectHostPlanNos(memberNo);
        for (Long planNo : hostPlanNos) {
            Long newHostMemberNo = travelMapper.selectFirstGuestMemberNo(planNo, memberNo);
            if (newHostMemberNo != null) {
                // 다른 활성 게스트가 있으면 호스트 위임
                travelMapper.updatePlanHost(planNo, newHostMemberNo, memberNo);
            } else {
                // 혼자인 계획은 FK 순서대로 완전 삭제
                travelMapper.deleteHistoryByPlanNo(planNo);
                travelMapper.deleteExpenseByPlanNo(planNo);
                travelMapper.deleteItineraryByPlanNo(planNo);
                travelMapper.deletePlanGuestLeaveByPlanNo(planNo);
                travelMapper.deletePlanGuestByPlanNo(planNo);
                travelMapper.deleteInvitationByPlanNo(planNo);
                travelMapper.deletePlan(planNo, memberNo);
            }
        }
    }


    /* ----------------------------------------
       직접 초대 관리
    ---------------------------------------- */

    // 받은 PENDING 초대 목록 조회
    public List<InvitationVo> getReceivedInvitations(Long memberNo)
    {
        return travelMapper.selectReceivedInvitations(memberNo);
    }

    /**
     * 특정 회원에게 직접 초대 전송 (호스트 전용)
     * - 이미 참여 중이거나 PENDING 중복 초대면 false
     * @return 성공 여부
     */
    @Transactional
    public boolean sendInvitation(Long planNo, Long inviteeMemberNo)
    {
        if (travelMapper.selectPlanGuestExists(planNo, inviteeMemberNo) > 0) return false;
        if (travelMapper.countDuplicateInvitation(planNo, inviteeMemberNo) > 0) return false;
        travelMapper.insertTargetedInvitation(planNo, inviteeMemberNo);
        return true;
    }

    /**
     * 초대 수락 - PENDING → ACCEPTED, PLAN_GUEST 등록
     * @return false: 초대 없음 / 본인 아님 / 이미 처리됨 / 게스트 8명 초과
     */
    @Transactional
    public boolean acceptInvitation(Long invitationNo, Long memberNo)
    {
        InvitationVo inv = travelMapper.selectInvitationByNo(invitationNo);
        if (inv == null || !memberNo.equals(inv.getInviteeMemberNo())) return false;
        if (!"PENDING".equals(inv.getInviteStatus())) return false;

        boolean alreadyGuest = travelMapper.selectPlanGuestExists(inv.getPlanNo(), memberNo) > 0;

        // 게스트 8명 제한 - 이미 참여 중이 아닌 경우에만 체크
        if (!alreadyGuest && travelMapper.countActiveGuests(inv.getPlanNo()) >= 8) {
            return false;
        }

        int updated = travelMapper.updateInviteStatus(invitationNo, memberNo, "ACCEPTED");
        if (updated == 0) return false;

        if (!alreadyGuest) {
            travelMapper.insertPlanGuest(inv.getPlanNo(), memberNo);
        }
        return true;
    }

    /**
     * 초대 거절 - PENDING → DECLINED
     * @return false: 초대 없음 / 본인 아님 / 이미 처리됨
     */
    @Transactional
    public boolean declineInvitation(Long invitationNo, Long memberNo)
    {
        InvitationVo inv = travelMapper.selectInvitationByNo(invitationNo);
        if (inv == null || !memberNo.equals(inv.getInviteeMemberNo())) return false;
        if (!"PENDING".equals(inv.getInviteStatus())) return false;

        int updated = travelMapper.updateInviteStatus(invitationNo, memberNo, "DECLINED");
        return updated > 0;
    }


    /* ----------------------------------------
       계획 삭제
    ---------------------------------------- */

    /**
     * 계획 삭제 (호스트만, 하드 딜리트)
     * FK 제약 순서: 이력 → 비용 → 일정 → 게스트탈퇴 → 게스트 → 초대코드 → 계획
     */
    @Transactional
    public void deletePlan(Long planNo, Long memberNo)
    {
        travelMapper.deleteHistoryByPlanNo(planNo);
        travelMapper.deleteExpenseByPlanNo(planNo);
        travelMapper.deleteItineraryByPlanNo(planNo);
        travelMapper.deletePlanGuestLeaveByPlanNo(planNo);
        travelMapper.deletePlanGuestByPlanNo(planNo);
        travelMapper.deleteInvitationByPlanNo(planNo);
        travelMapper.deletePlan(planNo, memberNo);
    }
}