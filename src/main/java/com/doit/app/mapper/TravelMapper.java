/*===============================================
    TravelMapper.java
    - 여행 계획 관련 MyBatis Mapper 인터페이스
    - travelMapper.xml 과 연결
===============================================*/
package com.doit.app.mapper;

import com.doit.app.domain.GuestVo;
import com.doit.app.domain.InvitationVo;
import com.doit.app.domain.PlanVo;
import com.doit.app.domain.TravelVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface TravelMapper
{
    /* ----------------------------------------
       계획 조회
    ---------------------------------------- */

    // 회원별 여행계획 목록 조회 (최상위 계획만)
    List<TravelVo> selectPlansByMemberNo(Long memberNo);

    /** 계획 단건 조회 */
    PlanVo selectPlanDetail(@Param("planNo") Long planNo);

    /** 내 계획 목록 (호스트, 필터 선택적 적용) */
    List<PlanVo> selectMyPlans(@Param("memberNo")  Long   memberNo,
                               @Param("theme")     String theme,
                               @Param("startDate") String startDate,
                               @Param("endDate")   String endDate);

    /** 참여 중인 계획 목록 (게스트, 필터 선택적 적용) */
    List<PlanVo> selectJoinedPlans(@Param("memberNo")  Long   memberNo,
                                   @Param("theme")     String theme,
                                   @Param("startDate") String startDate,
                                   @Param("endDate")   String endDate);

    /** 테마명 목록 (필터 드롭다운용) */
    List<String> selectThemeNames();

    /* ----------------------------------------
       계획 생성 / 수정 / 삭제
    ---------------------------------------- */

    /** 호스트로 보유 중인 계획 수 (20개 제한 체크용) */
    int countHostPlans(@Param("memberNo") Long memberNo);

    /**
     * 날짜 겹침 검사
     * - 회원이 참여 중인 계획과 startDt ~ endDt 범위가 겹치면 COUNT > 0
     * - excludePlanNo : 수정 시 자신 제외 / 생성 시 null
     */
    int checkDateOverlap(@Param("memberNo")      Long   memberNo,
                         @Param("startDt")       String startDt,
                         @Param("endDt")         String endDt,
                         @Param("excludePlanNo") Long   excludePlanNo);

    /** 새 계획 저장 (생성된 PK가 planVo.id 에 채워짐) */
    void insertPlan(PlanVo planVo);

    /** 호스트를 PLAN_GUEST 에 등록 */
    void insertPlanGuest(@Param("planNo") Long planNo,
                         @Param("memberNo") Long memberNo);

    /** 초대코드를 TRAVEL_INVITATION 에 저장 */
    void insertInvitation(@Param("planNo") Long planNo,
                          @Param("inviteCode") String inviteCode);

    /** 기존 코드 기반 초대(INVITE_CODE)만 삭제 — 직접 초대(INVITEE_MEMBER_NO)는 유지 */
    void deleteInviteCodeByPlanNo(@Param("planNo") Long planNo);

    /** 호스트 위임 */
    int updatePlanHost(@Param("planNo")             Long planNo,
                       @Param("newHostMemberNo")    Long newHostMemberNo,
                       @Param("currentHostMemberNo") Long currentHostMemberNo);

    /** 계획 수정 (호스트만) */
    void updatePlan(PlanVo planVo);

    /** 계획 공개/비공개 설정 변경 (호스트만) */
    int updatePlanVisibility(@Param("planNo")       Long planNo,
                             @Param("hostMemberNo") Long hostMemberNo,
                             @Param("isPublic")     int  isPublic);

    /* ----------------------------------------
       게스트 관리
    ---------------------------------------- */

    /** 활성 게스트 목록 조회 (PLAN_GUEST_LEAVE 없는 게스트만) */
    List<GuestVo> selectGuests(@Param("planNo") Long planNo);

    /** 게스트 편집 권한 변경 (canEdit: 1=편집 가능, 0=읽기 전용) */
    int updateGuestPermission(@Param("planNo")   Long planNo,
                              @Param("memberNo") Long memberNo,
                              @Param("canEdit")  int  canEdit);

    /** 활성 게스트 수 (8명 제한 체크용, 탈퇴/내보내기 제외) */
    int countActiveGuests(@Param("planNo") Long planNo);

    /** 초대코드로 planNo 조회 */
    Long selectPlanNoByInviteCode(@Param("inviteCode") String inviteCode);

    /** 이미 참여 중인지 확인 */
    int selectPlanGuestExists(@Param("planNo") Long planNo,
                              @Param("memberNo") Long memberNo);

    /** 특정 멤버의 PLAN_GUEST_NO 조회 */
    Long selectPlanGuestNoByMember(@Param("planNo") Long planNo,
                                   @Param("memberNo") Long memberNo);

    /** 게스트 탈퇴 이력 기록 */
    void insertPlanGuestLeave(@Param("planGuestNo") Long planGuestNo,
                              @Param("leaveType") String leaveType);

    /** 특정 게스트 삭제 */
    void deletePlanGuestByMember(@Param("planNo") Long planNo,
                                 @Param("memberNo") Long memberNo);

    /* ----------------------------------------
       탈퇴 처리 보조 (handleWithdrawal)
    ---------------------------------------- */

    /** 탈퇴 회원이 호스트인 계획 번호 목록 */
    List<Long> selectHostPlanNos(@Param("memberNo") Long memberNo);

    /** 계획의 활성 비호스트 게스트 중 가장 오래된 MEMBER_NO (없으면 null) */
    Long selectFirstGuestMemberNo(@Param("planNo")       Long planNo,
                                  @Param("hostMemberNo") Long hostMemberNo);

    /* ----------------------------------------
       직접 초대 (TRAVEL_INVITATION)
    ---------------------------------------- */

    /** 특정 회원에게 직접 초대 전송 */
    void insertTargetedInvitation(@Param("planNo")          Long planNo,
                                  @Param("inviteeMemberNo") Long inviteeMemberNo);

    /** 동일 플랜 PENDING 중복 초대 확인 */
    int countDuplicateInvitation(@Param("planNo")          Long planNo,
                                 @Param("inviteeMemberNo") Long inviteeMemberNo);

    /** 받은 PENDING 초대 목록 조회 */
    List<InvitationVo> selectReceivedInvitations(@Param("memberNo") Long memberNo);

    /** 초대 단건 조회 (수락/거절 소유권 확인용) */
    InvitationVo selectInvitationByNo(@Param("invitationNo") Long invitationNo);

    /** 초대 상태 변경 (PENDING → ACCEPTED / DECLINED) */
    int updateInviteStatus(@Param("invitationNo") Long   invitationNo,
                           @Param("memberNo")     Long   memberNo,
                           @Param("status")       String status);

    /* ----------------------------------------
       계획 삭제 (FK 순서 준수 필수)
    ---------------------------------------- */

    /** 계획 삭제 관련 - FK 순서: 이력→비용→소프트삭제이력→일정→게스트탈퇴→게스트→초대코드→계획 */
    void deleteHistoryByPlanNo(@Param("planNo") Long planNo);
    void deleteExpenseByPlanNo(@Param("planNo") Long planNo);
    void deleteDelRecordByPlanNo(@Param("planNo") Long planNo);
    void deleteItineraryByPlanNo(@Param("planNo") Long planNo);
    void deletePlanGuestLeaveByPlanNo(@Param("planNo") Long planNo);
    void deletePlanGuestByPlanNo(@Param("planNo") Long planNo);
    void deleteInvitationByPlanNo(@Param("planNo") Long planNo);
    void deletePlan(@Param("planNo") Long planNo, @Param("hostMemberNo") Long hostMemberNo);
}
