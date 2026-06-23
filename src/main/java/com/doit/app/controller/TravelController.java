/*===============================================
    TravelController.java
    - 여행 계획 컨트롤러
    - GET    /plans                                 : 계획 목록 페이지
    - POST   /plans                                 : 새 계획 생성
    - GET    /plans/{planNo}                        : 계획 상세 페이지
    - PUT    /plans/{planNo}                        : 계획 수정 (호스트)
    - DELETE /plans/{planNo}                        : 계획 삭제 (호스트)
    - POST   /plans/join                            : 초대코드로 계획 참여
    - DELETE /plans/{planNo}/guest/{memberId}       : 게스트 내보내기 (호스트)
    - POST   /plans/{planNo}/invite/member          : 직접 초대 전송 (호스트)
    - POST   /invitations/{invitationNo}/accept     : 초대 수락
    - POST   /invitations/{invitationNo}/decline    : 초대 거절
    - PUT    /plans/{planNo}/guest/{memberId}/permission : 게스트 편집 권한 변경 (호스트)
    - PUT    /plans/{planNo}/visibility                 : 공개/비공개 설정 변경 (호스트)
===============================================*/
package com.doit.app.controller;

import com.doit.app.domain.GuestVo;
import com.doit.app.domain.MemberVo;
import com.doit.app.domain.PlanVo;
import com.doit.app.mapper.TravelMapper;
import com.doit.app.service.ChecklistService;
import com.doit.app.service.ContentService;
import com.doit.app.service.ItineraryService;
import com.doit.app.service.TravelService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@Slf4j
public class TravelController
{
    private final TravelMapper      travelMapper;
    private final TravelService     travelService;
    private final ItineraryService  itineraryService;
    private final ContentService    contentService;
    private final ChecklistService  checklistService;

    /* ----------------------------------------
       세션 헬퍼
    ---------------------------------------- */

    private boolean isLoggedIn(HttpSession session)
    {
        return session.getAttribute("loginMember") != null;
    }

    private Long memberNo(HttpSession session)
    {
        MemberVo member = (MemberVo) session.getAttribute("loginMember");
        return member.getMemberNo();
    }


    /* ========================================================
       계획 목록 / 상세 페이지
    ======================================================== */

    @GetMapping("/plans")
    public String plansPage(@RequestParam(name = "theme",     required = false) String theme,
                            @RequestParam(name = "startDate", required = false) String startDate,
                            @RequestParam(name = "endDate",   required = false) String endDate,
                            Model model,
                            HttpSession session)
    {
        if (!isLoggedIn(session)) return "redirect:/login";

        Long memberNo = memberNo(session);

        List<PlanVo> myPlans     = travelMapper.selectMyPlans(memberNo, theme, startDate, endDate);
        List<PlanVo> joinedPlans = travelMapper.selectJoinedPlans(memberNo, theme, startDate, endDate);
        List<String> themes      = travelMapper.selectThemeNames();

        model.addAttribute("myPlans",     myPlans);
        model.addAttribute("joinedPlans", joinedPlans);
        model.addAttribute("themes",      themes);

        return "user/plans";
    }


    @PostMapping("/plans")
    @ResponseBody
    public Map<String, Object> createPlan(@RequestBody PlanVo planVo,
                                          HttpSession session)
    {
        if (!isLoggedIn(session)) return Map.of("error", "로그인이 필요합니다.");

        Long memberNo = memberNo(session);

        // 호스트 보유 계획 20개 제한
        if (travelMapper.countHostPlans(memberNo) >= 20)
            return Map.of("error", "계획은 최대 20개까지 생성할 수 있습니다.");

        // 날짜 겹침 검사 (생성이므로 자신 제외 없음 → null)
        if (travelMapper.checkDateOverlap(memberNo,
                                          planVo.getStartDate(),
                                          planVo.getEndDate(),
                                          null) > 0)
            return Map.of("error", "해당 날짜에 이미 참여 중인 계획이 있습니다.");

        Long planNo = travelService.createPlan(planVo, memberNo);
        return Map.of("id", planNo);
    }


    @GetMapping("/plans/{planNo}")
    public String planDetailPage(@PathVariable(name = "planNo") Long planNo,
                                 Model model,
                                 HttpSession session)
    {
        if (!isLoggedIn(session)) return "redirect:/login";

        Long   memberNo = memberNo(session);
        PlanVo plan     = travelMapper.selectPlanDetail(planNo);

        if (plan == null) return "redirect:/plans";

        boolean isHost = plan.getHostMemberNo() != null
                         && plan.getHostMemberNo().equals(memberNo);

        Long planGuestNo = itineraryService.getPlanGuestNo(planNo, memberNo);

        // 참여자(호스트 또는 활성 게스트)가 아니면 접근 불가
        if (!isHost && planGuestNo == null) return "redirect:/plans";

        List<GuestVo> guests = travelService.getGuests(planNo);

        // 호스트는 항상 편집 가능; 게스트는 PLAN_GUEST.CAN_EDIT 반영 (M7)
        boolean canEdit = isHost;
        if (!isHost && planGuestNo != null) {
            canEdit = guests.stream()
                            .filter(g -> g.getMemberId().equals(memberNo))
                            .map(GuestVo::isCanEdit)
                            .findFirst()
                            .orElse(false);
        }

        model.addAttribute("plan",         plan);
        model.addAttribute("isHost",       isHost);
        model.addAttribute("canEdit",      canEdit);
        model.addAttribute("memberNo",     memberNo);

        model.addAttribute("schedulesMap", itineraryService.getSchedulesMap(planNo));
        model.addAttribute("dayLabels",    itineraryService.getDayLabels(planNo, plan.getDayCount()));
        model.addAttribute("costSummary",          itineraryService.getCostSummary(planNo));
        model.addAttribute("totalCost",            itineraryService.getTotalCost(planNo));
        model.addAttribute("totalEstimatedCost",   itineraryService.getTotalEstimatedCost(planNo));
        model.addAttribute("history",      itineraryService.getHistory(planNo));

        model.addAttribute("themes",       travelMapper.selectThemeNames());
        model.addAttribute("expenseTypes", itineraryService.getExpenseTypeNames());
        model.addAttribute("cateList",     contentService.listCategory());

        model.addAttribute("guests",       guests);
        model.addAttribute("checklist",    checklistService.getChecklistItems(planNo));

        return "user/planDetail";
    }


    /* ========================================================
       초대코드 참여 / 게스트 내보내기
    ======================================================== */

    @PostMapping("/plans/join")
    @ResponseBody
    public ResponseEntity<?> joinPlan(@RequestBody Map<String, String> body,
                                      HttpSession session)
    {
        if (!isLoggedIn(session)) return ResponseEntity.status(401).body("로그인이 필요합니다.");

        String inviteCode = body.get("inviteCode");
        if (inviteCode == null || inviteCode.isBlank()) {
            return ResponseEntity.badRequest().body("초대 코드를 입력하세요.");
        }

        // 코드 유효성 확인 - null 이면 존재하지 않는 코드
        Long planNo = travelMapper.selectPlanNoByInviteCode(inviteCode.trim());
        if (planNo == null) return ResponseEntity.badRequest().body("유효하지 않은 초대 코드입니다.");

        Long memberNo = memberNo(session);

        // 이미 참여 중이면 인원 체크 없이 통과 (joinByInviteCode 내부에서 중복 INSERT 방지)
        // 신규 참여자만 8명 제한 적용
        if (travelMapper.selectPlanGuestExists(planNo, memberNo) == 0
                && travelMapper.countActiveGuests(planNo) >= 8) {
            return ResponseEntity.status(409).body("최대 8명까지 참여 가능합니다.");
        }

        travelService.joinByInviteCode(inviteCode.trim(), memberNo);
        return ResponseEntity.ok(Map.of("id", planNo));
    }


    @DeleteMapping("/plans/{planNo}/guest/{memberId}")
    @ResponseBody
    public ResponseEntity<?> kickGuest(@PathVariable(name = "planNo")   Long planNo,
                                       @PathVariable(name = "memberId") Long memberId,
                                       HttpSession session)
    {
        if (!isLoggedIn(session)) return ResponseEntity.status(401).body("로그인이 필요합니다.");

        Long   memberNo = memberNo(session);
        PlanVo plan     = travelMapper.selectPlanDetail(planNo);

        if (plan == null) return ResponseEntity.notFound().build();
        if (!plan.getHostMemberNo().equals(memberNo))
            return ResponseEntity.status(403).body("호스트만 내보내기를 할 수 있습니다.");
        if (memberId.equals(memberNo))
            return ResponseEntity.badRequest().body("본인을 내보낼 수 없습니다.");

        travelService.kickGuest(planNo, memberId);
        return ResponseEntity.ok().build();
    }


    /* ========================================================
       계획 수정 / 삭제
    ======================================================== */

    @PutMapping("/plans/{planNo}")
    @ResponseBody
    public ResponseEntity<?> updatePlan(@PathVariable(name = "planNo") Long planNo,
                                        @RequestBody PlanVo planVo,
                                        HttpSession session)
    {
        if (!isLoggedIn(session)) return ResponseEntity.status(401).body("로그인이 필요합니다.");

        Long   memberNo = memberNo(session);
        PlanVo plan     = travelMapper.selectPlanDetail(planNo);

        if (plan == null) return ResponseEntity.notFound().build();
        if (!plan.getHostMemberNo().equals(memberNo))
            return ResponseEntity.status(403).body("호스트만 수정할 수 있습니다.");

        planVo.setId(planNo);
        planVo.setHostMemberNo(memberNo);

        // 날짜 겹침 검사 (수정이므로 자신 planNo 제외)
        if (travelMapper.checkDateOverlap(memberNo,
                                          planVo.getStartDate(),
                                          planVo.getEndDate(),
                                          planNo) > 0)
            return ResponseEntity.status(409).body("해당 날짜에 이미 참여 중인 계획이 있습니다.");

        travelService.updatePlan(planVo);
        return ResponseEntity.ok().build();
    }


    /**
     * PUT /plans/{planNo}/visibility
     * - 계획 공개/비공개 설정 변경 (호스트만)
     * - body: { isPublic: 0(비공개) | 1(공개) }
     */
    @PutMapping("/plans/{planNo}/visibility")
    @ResponseBody
    public ResponseEntity<?> updatePlanVisibility(@PathVariable(name = "planNo") Long planNo,
                                                  @RequestBody Map<String, Integer> body,
                                                  HttpSession session)
    {
        if (!isLoggedIn(session)) return ResponseEntity.status(401).body("로그인이 필요합니다.");

        Long   memberNo = memberNo(session);
        PlanVo plan     = travelMapper.selectPlanDetail(planNo);

        if (plan == null) return ResponseEntity.notFound().build();
        if (!plan.getHostMemberNo().equals(memberNo))
            return ResponseEntity.status(403).body("호스트만 공개 설정을 변경할 수 있습니다.");

        Integer isPublic = body.get("isPublic");
        if (isPublic == null || (isPublic != 0 && isPublic != 1))
            return ResponseEntity.badRequest().body("isPublic 값은 0 또는 1이어야 합니다.");

        travelMapper.updatePlanVisibility(planNo, memberNo, isPublic);
        return ResponseEntity.ok().build();
    }


    @DeleteMapping("/plans/{planNo}/leave")
    @ResponseBody
    public ResponseEntity<?> leavePlan(@PathVariable(name = "planNo") Long planNo,
                                       HttpSession session)
    {
        if (!isLoggedIn(session)) return ResponseEntity.status(401).body("로그인이 필요합니다.");

        Long   memberNo = memberNo(session);
        PlanVo plan     = travelMapper.selectPlanDetail(planNo);

        if (plan == null) return ResponseEntity.notFound().build();
        if (plan.getHostMemberNo().equals(memberNo))
            return ResponseEntity.badRequest().body("호스트는 나갈 수 없습니다. 먼저 호스트를 위임하세요.");

        boolean ok = travelService.leavePlan(planNo, memberNo);
        return ok ? ResponseEntity.ok().build()
                  : ResponseEntity.badRequest().body("계획 참여자가 아닙니다.");
    }


    @DeleteMapping("/plans/{planNo}")
    @ResponseBody
    public ResponseEntity<?> deletePlan(@PathVariable(name = "planNo") Long planNo,
                                        HttpSession session)
    {
        if (!isLoggedIn(session)) return ResponseEntity.status(401).body("로그인이 필요합니다.");

        Long   memberNo = memberNo(session);
        PlanVo plan     = travelMapper.selectPlanDetail(planNo);

        if (plan == null) return ResponseEntity.notFound().build();
        if (!plan.getHostMemberNo().equals(memberNo))
            return ResponseEntity.status(403).body("호스트만 삭제할 수 있습니다.");

        // 호스트 외 활성 게스트가 있으면 삭제 불가
        boolean hasGuests = travelService.getGuests(planNo).stream()
                .anyMatch(g -> !g.isHost());
        if (hasGuests)
            return ResponseEntity.badRequest().body("참여 중인 멤버가 있습니다. 호스트 위임 또는 내보내기 후 삭제해주세요.");

        travelService.deletePlan(planNo, memberNo);
        return ResponseEntity.ok().build();
    }


    /* ========================================================
       호스트 위임 / 초대코드 재생성
    ======================================================== */

    /**
     * PUT /plans/{planNo}/host
     * - 호스트 위임 (호스트만)
     * - body: { newHostMemberNo }
     */
    @PutMapping("/plans/{planNo}/host")
    @ResponseBody
    public ResponseEntity<?> transferHost(@PathVariable(name = "planNo") Long planNo,
                                          @RequestBody Map<String, Long> body,
                                          HttpSession session)
    {
        if (!isLoggedIn(session)) return ResponseEntity.status(401).body("로그인이 필요합니다.");

        Long newHostMemberNo = body.get("newHostMemberNo");
        if (newHostMemberNo == null) return ResponseEntity.badRequest().body("newHostMemberNo 필수");

        Long   memberNo = memberNo(session);
        PlanVo plan     = travelMapper.selectPlanDetail(planNo);

        if (plan == null) return ResponseEntity.notFound().build();
        if (!plan.getHostMemberNo().equals(memberNo))
            return ResponseEntity.status(403).body("호스트만 위임할 수 있습니다.");
        if (newHostMemberNo.equals(memberNo))
            return ResponseEntity.badRequest().body("본인에게 위임할 수 없습니다.");

        boolean ok = travelService.transferHost(planNo, newHostMemberNo, memberNo);
        return ok ? ResponseEntity.ok().build()
                  : ResponseEntity.badRequest().body("위임에 실패했습니다.");
    }


    /*
      POST /plans/{planNo}/invite/member
      - 특정 회원에게 직접 초대 전송 (호스트만)
      - body: { inviteeMemberNo }
     */
    @PostMapping("/plans/{planNo}/invite/member")
    @ResponseBody
    public ResponseEntity<?> sendInvitation(@PathVariable(name = "planNo") Long planNo,
                                            @RequestBody Map<String, Long> body,
                                            HttpSession session)
    {
        if (!isLoggedIn(session)) return ResponseEntity.status(401).body("로그인이 필요합니다.");

        Long inviteeMemberNo = body.get("inviteeMemberNo");
        if (inviteeMemberNo == null) return ResponseEntity.badRequest().body("inviteeMemberNo 필수");

        Long   memberNo = memberNo(session);
        PlanVo plan     = travelMapper.selectPlanDetail(planNo);

        if (plan == null) return ResponseEntity.notFound().build();
        if (!plan.getHostMemberNo().equals(memberNo))
            return ResponseEntity.status(403).body("호스트만 초대할 수 있습니다.");
        if (inviteeMemberNo.equals(memberNo))
            return ResponseEntity.badRequest().body("본인을 초대할 수 없습니다.");

        boolean ok = travelService.sendInvitation(planNo, inviteeMemberNo);
        return ok ? ResponseEntity.ok().build()
                  : ResponseEntity.status(409).body("이미 참여 중이거나 초대가 진행 중입니다.");
    }


    /**
     * POST /invitations/{invitationNo}/accept
     * - 초대 수락 - PLAN_GUEST 등록 + INVITE_STATUS → ACCEPTED
     */
    @PostMapping("/invitations/{invitationNo}/accept")
    @ResponseBody
    public ResponseEntity<?> acceptInvitation(@PathVariable(name = "invitationNo") Long invitationNo,
                                              HttpSession session)
    {
        if (!isLoggedIn(session)) return ResponseEntity.status(401).body("로그인이 필요합니다.");

        boolean ok = travelService.acceptInvitation(invitationNo, memberNo(session));
        return ok ? ResponseEntity.ok().build()
                  : ResponseEntity.status(409).body("초대를 처리할 수 없습니다.");
    }


    /**
     * POST /invitations/{invitationNo}/decline
     * - 초대 거절 - INVITE_STATUS → DECLINED
     */
    @PostMapping("/invitations/{invitationNo}/decline")
    @ResponseBody
    public ResponseEntity<?> declineInvitation(@PathVariable(name = "invitationNo") Long invitationNo,
                                               HttpSession session)
    {
        if (!isLoggedIn(session)) return ResponseEntity.status(401).body("로그인이 필요합니다.");

        boolean ok = travelService.declineInvitation(invitationNo, memberNo(session));
        return ok ? ResponseEntity.ok().build()
                  : ResponseEntity.status(409).body("초대를 처리할 수 없습니다.");
    }


    /**
     * POST /plans/{planNo}/invite
     * - 초대코드 재생성 (호스트만)
     * - 응답: { inviteCode: "..." }
     */
    @PostMapping("/plans/{planNo}/invite")
    @ResponseBody
    public ResponseEntity<?> regenerateInvite(@PathVariable(name = "planNo") Long planNo,
                                              HttpSession session)
    {
        if (!isLoggedIn(session)) return ResponseEntity.status(401).body("로그인이 필요합니다.");

        Long   memberNo = memberNo(session);
        PlanVo plan     = travelMapper.selectPlanDetail(planNo);

        if (plan == null) return ResponseEntity.notFound().build();
        if (!plan.getHostMemberNo().equals(memberNo))
            return ResponseEntity.status(403).body("호스트만 재생성할 수 있습니다.");

        String code = travelService.regenerateInviteCode(planNo);
        return ResponseEntity.ok(Map.of("inviteCode", code));
    }


    /**
     * PUT /plans/{planNo}/guest/{memberId}/permission
     * - 게스트 편집 권한 변경 (호스트만)
     * - body: { canEdit: 0(읽기 전용) | 1(편집 가능) }
     * - 호스트 본인 권한 변경 불가
     */
    @PutMapping("/plans/{planNo}/guest/{memberId}/permission")
    @ResponseBody
    public ResponseEntity<?> updateGuestPermission(@PathVariable(name = "planNo")   Long planNo,
                                                   @PathVariable(name = "memberId") Long memberId,
                                                   @RequestBody Map<String, Integer> body,
                                                   HttpSession session)
    {
        if (!isLoggedIn(session)) return ResponseEntity.status(401).body("로그인이 필요합니다.");

        Long   memberNo = memberNo(session);
        PlanVo plan     = travelMapper.selectPlanDetail(planNo);

        if (plan == null) return ResponseEntity.notFound().build();
        if (!plan.getHostMemberNo().equals(memberNo))
            return ResponseEntity.status(403).body("호스트만 권한을 변경할 수 있습니다.");

        // 호스트 본인 권한 변경 불가
        if (memberId.equals(memberNo))
            return ResponseEntity.badRequest().body("호스트 본인의 권한은 변경할 수 없습니다.");

        Integer canEdit = body.get("canEdit");
        if (canEdit == null || (canEdit != 0 && canEdit != 1))
            return ResponseEntity.badRequest().body("canEdit 값은 0 또는 1이어야 합니다.");

        int rows = travelMapper.updateGuestPermission(planNo, memberId, canEdit);
        return rows > 0 ? ResponseEntity.ok().build()
                        : ResponseEntity.badRequest().body("해당 게스트를 찾을 수 없습니다.");
    }
}
