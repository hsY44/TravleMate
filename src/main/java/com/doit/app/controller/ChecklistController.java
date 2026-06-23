/*===============================================
    ChecklistController.java
    - 여행 계획 체크리스트(준비물) AJAX 컨트롤러
    - GET    /plans/{planNo}/checklist         : 목록 조회
    - POST   /plans/{planNo}/checklist         : 항목 추가
    - PUT    /plans/{planNo}/checklist/{no}    : 항목 수정 (내용 or 체크 상태)
    - DELETE /plans/{planNo}/checklist/{no}    : 항목 삭제
    - 접근 권한 : 계획 참여자(호스트 + 활성 게스트) 모두 허용
===============================================*/
package com.doit.app.controller;

import com.doit.app.domain.MemberVo;
import com.doit.app.service.ChecklistService;
import com.doit.app.service.ItineraryService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Controller
@RequiredArgsConstructor
@Slf4j
public class ChecklistController
{
    private final ChecklistService  checklistService;
    private final ItineraryService  itineraryService;

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

    /* ----------------------------------------
       참여자 확인 공통 헬퍼
       - itineraryMapper.selectPlanGuestNo 재사용
       - 호스트도 PLAN_GUEST 에 등록되므로 null 이면 비참여자
    ---------------------------------------- */

    private boolean isParticipant(Long planNo, Long memberNo)
    {
        return itineraryService.getPlanGuestNo(planNo, memberNo) != null;
    }


    /* ========================================================
       체크리스트 CRUD
    ======================================================== */

    /**
     * GET /plans/{planNo}/checklist
     * - 체크리스트 목록 조회 (JSON)
     * - 응답: List<ChecklistVo>
     */
    @GetMapping("/plans/{planNo}/checklist")
    @ResponseBody
    public ResponseEntity<?> getChecklist(@PathVariable(name = "planNo") Long planNo,
                                          HttpSession session)
    {
        if (!isLoggedIn(session)) return ResponseEntity.status(401).body("로그인이 필요합니다.");
        if (!isParticipant(planNo, memberNo(session)))
            return ResponseEntity.status(403).body("계획 참여자가 아닙니다.");

        try {
            return ResponseEntity.ok(checklistService.getChecklistItems(planNo));
        } catch (Exception e) {
            log.info("getChecklist : ", e);
            return ResponseEntity.internalServerError().build();
        }
    }


    /**
     * POST /plans/{planNo}/checklist
     * - 체크리스트 항목 추가
     * - body: { content: "..." }
     * - 응답: 200 OK
     */
    @PostMapping("/plans/{planNo}/checklist")
    @ResponseBody
    public ResponseEntity<?> addChecklistItem(@PathVariable(name = "planNo") Long planNo,
                                              @RequestBody Map<String, Object> body,
                                              HttpSession session)
    {
        if (!isLoggedIn(session)) return ResponseEntity.status(401).body("로그인이 필요합니다.");
        if (!isParticipant(planNo, memberNo(session)))
            return ResponseEntity.status(403).body("계획 참여자가 아닙니다.");

        String content = (String) body.get("content");
        if (content == null || content.isBlank())
            return ResponseEntity.badRequest().body("content 는 필수입니다.");

        try {
            checklistService.addChecklistItem(planNo, content.trim());
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.info("addChecklistItem : ", e);
            return ResponseEntity.internalServerError().build();
        }
    }


    /**
     * PUT /plans/{planNo}/checklist/{no}
     * - 항목 내용 수정 또는 체크 상태 변경
     * - body: { content: "..." }  또는  { isChecked: 0|1 }  (둘 다 가능)
     * - 응답: 200 OK
     */
    @PutMapping("/plans/{planNo}/checklist/{no}")
    @ResponseBody
    public ResponseEntity<?> updateChecklistItem(@PathVariable(name = "planNo") Long planNo,
                                                 @PathVariable(name = "no")     Long no,
                                                 @RequestBody Map<String, Object> body,
                                                 HttpSession session)
    {
        if (!isLoggedIn(session)) return ResponseEntity.status(401).body("로그인이 필요합니다.");
        if (!isParticipant(planNo, memberNo(session)))
            return ResponseEntity.status(403).body("계획 참여자가 아닙니다.");

        String  content   = (String) body.get("content");
        Integer isChecked = body.get("isChecked") != null
                            ? Integer.parseInt(body.get("isChecked").toString()) : null;

        if (content == null && isChecked == null)
            return ResponseEntity.badRequest().body("content 또는 isChecked 가 필요합니다.");
        if (isChecked != null && isChecked != 0 && isChecked != 1)
            return ResponseEntity.badRequest().body("isChecked 값은 0 또는 1이어야 합니다.");

        try {
            boolean updated = checklistService.updateChecklistItem(no, planNo, content, isChecked);
            return updated ? ResponseEntity.ok().build()
                           : ResponseEntity.notFound().build();
        } catch (Exception e) {
            log.info("updateChecklistItem : ", e);
            return ResponseEntity.internalServerError().build();
        }
    }


    /**
     * DELETE /plans/{planNo}/checklist/{no}
     * - 체크리스트 항목 삭제
     * - 응답: 200 OK
     */
    @DeleteMapping("/plans/{planNo}/checklist/{no}")
    @ResponseBody
    public ResponseEntity<?> deleteChecklistItem(@PathVariable(name = "planNo") Long planNo,
                                                 @PathVariable(name = "no")     Long no,
                                                 HttpSession session)
    {
        if (!isLoggedIn(session)) return ResponseEntity.status(401).body("로그인이 필요합니다.");
        if (!isParticipant(planNo, memberNo(session)))
            return ResponseEntity.status(403).body("계획 참여자가 아닙니다.");

        try {
            boolean deleted = checklistService.removeChecklistItem(no, planNo);
            return deleted ? ResponseEntity.ok().build()
                           : ResponseEntity.notFound().build();
        } catch (Exception e) {
            log.info("deleteChecklistItem : ", e);
            return ResponseEntity.internalServerError().build();
        }
    }
}
