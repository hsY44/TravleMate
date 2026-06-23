/*===============================================
    ItineraryController.java
    - 여행 일정 AJAX 컨트롤러
    - 사용자: 일정 CRUD  (GET/POST/PUT/DELETE /plans/{planNo}/itinerary/...)
    - 관리자: 편집종류 관리 (GET/POST/PUT /admin/itineraryActionType/...)
===============================================*/
package com.doit.app.controller;

import com.doit.app.domain.ActionTypeVo;
import com.doit.app.domain.AdminVo;
import com.doit.app.domain.MemberVo;
import com.doit.app.domain.ScheduleVo;
import com.doit.app.service.ItineraryService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@Slf4j
public class ItineraryController
{
    private final ItineraryService itineraryService;

    /* ----------------------------------------
       세션 헬퍼
    ---------------------------------------- */

    private boolean isMemberLoggedIn(HttpSession session)
    {
        return session.getAttribute("loginMember") != null;
    }

    private Long memberNo(HttpSession session)
    {
        MemberVo member = (MemberVo) session.getAttribute("loginMember");
        return member.getMemberNo();
    }

    private boolean isAdminLoggedIn(HttpSession session)
    {
        return session.getAttribute("loginAdmin") != null;
    }


    /* ========================================================
       [사용자] 일정 CRUD  - /plans/{planNo}/itinerary/...
    ======================================================== */

    /**
     * GET /plans/{planNo}/itinerary/{no}
     * - 일정 단건 조회 (수정 모달 초기값 로딩용)
     * - 응답: ScheduleVo JSON
     */
    @GetMapping("/plans/{planNo}/itinerary/{no}")
    @ResponseBody
    public ResponseEntity<?> getSchedule(@PathVariable(name = "planNo") Long planNo,
                                         @PathVariable(name = "no")     Long no,
                                         HttpSession session)
    {
        if (!isMemberLoggedIn(session)) {
            return ResponseEntity.status(401).body("로그인이 필요합니다.");
        }

        Long planGuestNo = itineraryService.getPlanGuestNo(planNo, memberNo(session));
        if (planGuestNo == null) {
            return ResponseEntity.status(403).body("계획 참여자가 아닙니다.");
        }

        try {
            ScheduleVo sc = itineraryService.getSchedule(no, planNo);
            if (sc == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(sc);
        } catch (Exception e) {
            log.info("getSchedule : ", e);
            return ResponseEntity.internalServerError().build();
        }
    }


    /**
     * POST /plans/{planNo}/itinerary
     * - 일정 추가
     * - 요청 body (JSON):
     *   { itineraryDt, time, title, content, contentNo(선택),
     *     cost(선택), estimatedCost(선택), costCategory(선택),
     *     paymentMethod(선택), expenseMemo(선택) }
     * - 응답: 생성된 itineraryNo
     */
    @PostMapping("/plans/{planNo}/itinerary")
    @ResponseBody
    public ResponseEntity<?> addSchedule(@PathVariable(name = "planNo") Long planNo,
                                         @RequestBody Map<String, Object> body,
                                         HttpSession session)
    {
        if (!isMemberLoggedIn(session)) {
            return ResponseEntity.status(401).body("로그인이 필요합니다.");
        }

        ScheduleVo sc = buildScheduleVo(body, planNo, null);

        long   cost         = parseLong(body.get("cost"));
        String costCategory = (String) body.getOrDefault("costCategory", "기타");

        Long memberNo    = memberNo(session);
        Long planGuestNo = itineraryService.getPlanGuestNo(planNo, memberNo);
        if (planGuestNo == null) {
            return ResponseEntity.status(403).body("계획 참여자가 아닙니다.");
        }
        if (!itineraryService.canGuestEdit(planNo, memberNo)) {
            return ResponseEntity.status(403).body("읽기 전용 권한으로 일정을 편집할 수 없습니다.");
        }

        // 편집 잠금 기간이면 서비스에서 RuntimeException → 423 Locked 반환
        try {
            itineraryService.addSchedule(sc, cost, costCategory, planGuestNo);
        } catch (RuntimeException e) {
            return ResponseEntity.status(423).body(e.getMessage());
        }

        return ResponseEntity.ok(Map.of("itineraryNo", sc.getId()));
    }


    /**
     * PUT /plans/{planNo}/itinerary/{no}
     * - 일정 수정
     * - 요청 body (JSON): addSchedule 과 동일 구조
     * - 응답: 200 OK
     */
    @PutMapping("/plans/{planNo}/itinerary/{no}")
    @ResponseBody
    public ResponseEntity<?> editSchedule(@PathVariable(name = "planNo") Long planNo,
                                          @PathVariable(name = "no")     Long no,
                                          @RequestBody Map<String, Object> body,
                                          HttpSession session)
    {
        if (!isMemberLoggedIn(session)) {
            return ResponseEntity.status(401).body("로그인이 필요합니다.");
        }

        ScheduleVo sc = buildScheduleVo(body, planNo, no);

        long   cost         = parseLong(body.get("cost"));
        String costCategory = (String) body.getOrDefault("costCategory", "기타");

        Long memberNo    = memberNo(session);
        Long planGuestNo = itineraryService.getPlanGuestNo(planNo, memberNo);
        if (planGuestNo == null) {
            return ResponseEntity.status(403).body("계획 참여자가 아닙니다.");
        }
        if (!itineraryService.canGuestEdit(planNo, memberNo)) {
            return ResponseEntity.status(403).body("읽기 전용 권한으로 일정을 편집할 수 없습니다.");
        }

        // 편집 잠금 기간이면 서비스에서 RuntimeException → 423 Locked 반환
        try {
            itineraryService.editSchedule(sc, cost, costCategory, planGuestNo);
        } catch (RuntimeException e) {
            return ResponseEntity.status(423).body(e.getMessage());
        }

        return ResponseEntity.ok().build();
    }


    /**
     * DELETE /plans/{planNo}/itinerary/{no}
     * - 일정 삭제 (비용/이력 포함)
     * - 응답: 200 OK
     */
    @DeleteMapping("/plans/{planNo}/itinerary/{no}")
    @ResponseBody
    public ResponseEntity<?> deleteSchedule(@PathVariable(name = "planNo") Long planNo,
                                            @PathVariable(name = "no")     Long no,
                                            HttpSession session)
    {
        if (!isMemberLoggedIn(session)) {
            return ResponseEntity.status(401).body("로그인이 필요합니다.");
        }

        Long memberNo    = memberNo(session);
        Long planGuestNo = itineraryService.getPlanGuestNo(planNo, memberNo);
        if (planGuestNo == null) {
            return ResponseEntity.status(403).body("계획 참여자가 아닙니다.");
        }
        if (!itineraryService.canGuestEdit(planNo, memberNo)) {
            return ResponseEntity.status(403).body("읽기 전용 권한으로 일정을 편집할 수 없습니다.");
        }

        // 편집 잠금 기간이면 서비스에서 RuntimeException → 423 Locked 반환
        try {
            itineraryService.removeSchedule(no, planNo, planGuestNo);
        } catch (RuntimeException e) {
            return ResponseEntity.status(423).body(e.getMessage());
        }

        return ResponseEntity.ok().build();
    }


    /* ========================================================
       [관리자] 편집 종류 (ACTION_TYPE)
       - /admin/itineraryActionType
    ======================================================== */

    /**
     * GET /admin/itineraryActionType
     * - 편집 종류 목록 페이지 렌더링
     * - model: actionTypes (List<Map>)
     */
    @GetMapping("/admin/itineraryActionType")
    public String actionTypePage(Model model, HttpSession session)
    {
        if (!isAdminLoggedIn(session)) {
            return "redirect:/admin/login";
        }

        try {
            List<ActionTypeVo> types = itineraryService.getAllActionTypes();
            model.addAttribute("actionTypes", types);
        } catch (Exception e) {
            log.info("actionTypePage : ", e);
        }

        return "admin/itineraryActionType";
    }


    /**
     * POST /admin/itineraryActionType
     * - 편집 종류 추가 또는 수정 (코드 중복 시 UPDATE)
     * - 요청 파라미터: cd, nm
     * - 응답: 200 OK (AJAX)
     */
    @PostMapping("/admin/itineraryActionType")
    @ResponseBody
    public ResponseEntity<?> saveActionType(@RequestParam(name = "cd") String cd,
                                            @RequestParam(name = "nm") String nm,
                                            HttpSession session)
    {
        if (!isAdminLoggedIn(session)) {
            return ResponseEntity.status(401).body("관리자 로그인이 필요합니다.");
        }

        try {
            itineraryService.saveActionType(cd.trim(), nm.trim());
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.info("saveActionType : ", e);
            return ResponseEntity.internalServerError().build();
        }
    }


    /**
     * PUT /admin/itineraryActionType/{cd}
     * - 편집 종류 이름 수정
     * - 요청 파라미터: nm
     * - 응답: 200 OK (AJAX)
     */
    @PutMapping("/admin/itineraryActionType/{cd}")
    @ResponseBody
    public ResponseEntity<?> updateActionType(@PathVariable(name = "cd") String cd,
                                              @RequestParam(name = "nm") String nm,
                                              HttpSession session)
    {
        if (!isAdminLoggedIn(session)) {
            return ResponseEntity.status(401).body("관리자 로그인이 필요합니다.");
        }

        try {
            itineraryService.saveActionType(cd.trim(), nm.trim());
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.info("updateActionType : ", e);
            return ResponseEntity.internalServerError().build();
        }
    }


    /* ----------------------------------------
       private 헬퍼
    ---------------------------------------- */

    /** Map body 에서 ScheduleVo 를 생성 */
    private ScheduleVo buildScheduleVo(Map<String, Object> body, Long planNo, Long id)
    {
        ScheduleVo sc = new ScheduleVo();
        sc.setId(id);
        sc.setPlanNo(planNo);
        sc.setItineraryDt((String) body.get("itineraryDt"));
        sc.setTime((String) body.get("time"));
        sc.setTitle((String) body.get("title"));
        sc.setContent((String) body.get("content"));

        Object cnRaw = body.get("contentNo");
        if (cnRaw != null && !cnRaw.toString().isBlank()) {
            sc.setContentNo(Long.parseLong(cnRaw.toString()));
        }

        // 비용 관련 필드 (서비스에서 insertExpense 에 직접 전달)
        sc.setEstimatedCost(parseLong(body.get("estimatedCost")));
        sc.setPaymentMethod((String) body.get("paymentMethod"));
        sc.setExpenseMemo((String) body.get("expenseMemo"));

        return sc;
    }

    /** Object → long 변환 (null 또는 빈값이면 0) */
    private long parseLong(Object val)
    {
        if (val == null || val.toString().isBlank()) return 0L;
        try { return Long.parseLong(val.toString()); }
        catch (NumberFormatException e) { return 0L; }
    }
}
