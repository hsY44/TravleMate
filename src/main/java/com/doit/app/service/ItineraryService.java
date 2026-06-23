/*===============================================
    ItineraryService.java
===============================================*/
package com.doit.app.service;

import com.doit.app.domain.ActionTypeVo;
import com.doit.app.domain.CostSummaryVo;
import com.doit.app.domain.HistoryVo;
import com.doit.app.domain.PlanDatesVo;
import com.doit.app.domain.ScheduleVo;
import com.doit.app.mapper.ItineraryMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Slf4j
public class ItineraryService
{
    private final ItineraryMapper itineraryMapper;

    /* -- planDetail.jsp model 구성 -- */

    public Map<Integer, List<ScheduleVo>> getSchedulesMap(Long planNo) {
        String startDateStr = itineraryMapper.selectPlanStartDate(planNo);
        List<ScheduleVo> schedules = itineraryMapper.selectSchedules(planNo);
        Map<Integer, List<ScheduleVo>> map = new LinkedHashMap<>();
        if (startDateStr == null || schedules.isEmpty()) return map;

        LocalDate startDate = LocalDate.parse(startDateStr);
        for (ScheduleVo sc : schedules) {
            LocalDate itDate = LocalDate.parse(sc.getItineraryDt());
            int dayIdx = (int) ChronoUnit.DAYS.between(startDate, itDate);
            sc.setDayIndex(dayIdx);
            sc.setDayLabel(itDate.format(DateTimeFormatter.ofPattern("MM-dd")));
            map.computeIfAbsent(dayIdx, k -> new ArrayList<>()).add(sc);
        }
        return map;
    }

    public List<String> getDayLabels(Long planNo, int dayCount) {
        String startDateStr = itineraryMapper.selectPlanStartDate(planNo);
        List<String> labels = new ArrayList<>();
        if (startDateStr == null || dayCount <= 0) return labels;

        LocalDate startDate = LocalDate.parse(startDateStr);
        for (int i = 0; i < dayCount; i++) {
            LocalDate d = startDate.plusDays(i);
            labels.add("Day " + (i + 1) + " (" + d.format(DateTimeFormatter.ofPattern("MM-dd")) + ")");
        }
        return labels;
    }

    public List<CostSummaryVo> getCostSummary(Long planNo) {
        return itineraryMapper.selectCostSummary(planNo);
    }

    public long getTotalCost(Long planNo) {
        return itineraryMapper.selectTotalCost(planNo);
    }

    public long getTotalEstimatedCost(Long planNo) {
        return itineraryMapper.selectTotalEstimatedCost(planNo);
    }

    public List<HistoryVo> getHistory(Long planNo) {
        return itineraryMapper.selectHistory(planNo);
    }

    /** 비용 카테고리 목록 반환 (드롭다운용 - DB 드리븐) */
    public List<String> getExpenseTypeNames() {
        return itineraryMapper.selectExpenseTypeNames();
    }

    /* -- 일정 CRUD -- */

    public ScheduleVo getSchedule(Long no, Long planNo) {
        return itineraryMapper.selectSchedule(no, planNo);
    }

    @Transactional
    public void addSchedule(ScheduleVo sc, long cost, String costCategory, Long planGuestNo) {
        // 편집 가능 기간이 아니면 RuntimeException - 컨트롤러에서 catch 후 423 반환
        assertEditable(sc.getPlanNo());
        itineraryMapper.insertSchedule(sc);
        // 실제 비용 또는 예상 비용이 있으면 ITINERARY_EXPENSE 저장
        if (cost > 0 || sc.getEstimatedCost() > 0)
            itineraryMapper.insertExpense(sc.getId(), cost, sc.getEstimatedCost(),
                                          costCategory, sc.getPaymentMethod(), sc.getExpenseMemo());
        itineraryMapper.insertHistory(sc.getPlanNo(), sc.getId(), "생성", planGuestNo, buildCreateSummary(sc, cost));
    }

    @Transactional
    public void editSchedule(ScheduleVo sc, long cost, String costCategory, Long planGuestNo) {
        // 편집 가능 기간이 아니면 RuntimeException - 컨트롤러에서 catch 후 423 반환
        assertEditable(sc.getPlanNo());
        // selectSchedule 은 NOT EXISTS(DEL) 필터 적용 → 삭제된 일정이면 null
        ScheduleVo old = itineraryMapper.selectSchedule(sc.getId(), sc.getPlanNo());
        if (old == null) throw new RuntimeException("존재하지 않거나 이미 삭제된 일정입니다.");
        String changeSummary = buildChangeSummary(old, sc, cost);
        itineraryMapper.deleteExpenseByItineraryNo(sc.getId());
        itineraryMapper.updateSchedule(sc);
        // 실제 비용 또는 예상 비용이 있으면 ITINERARY_EXPENSE 저장
        if (cost > 0 || sc.getEstimatedCost() > 0)
            itineraryMapper.insertExpense(sc.getId(), cost, sc.getEstimatedCost(),
                                          costCategory, sc.getPaymentMethod(), sc.getExpenseMemo());
        itineraryMapper.insertHistory(sc.getPlanNo(), sc.getId(), "수정", planGuestNo, changeSummary);
    }

    /* 생성 이력: 일정 제목만 저장 */
    private String buildCreateSummary(ScheduleVo sc, long cost) {
        return capBytes(sc.getTitle(), 195);
    }

    /* 수정 이력: "제목 (날짜 수정/메모 수정/5,000원 → 10,000원)" */
    private String buildChangeSummary(ScheduleVo old, ScheduleVo sc, long newCost) {
        List<String> changed = new ArrayList<>();
        if (!Objects.equals(old.getTitle(), sc.getTitle()))               changed.add("제목 수정");
        if (!Objects.equals(old.getItineraryDt(), sc.getItineraryDt()))   changed.add("날짜 수정");
        if (!Objects.equals(nvl(old.getTime()), nvl(sc.getTime())))       changed.add("시간 수정");
        if (!Objects.equals(nvl(old.getContent()), nvl(sc.getContent()))) changed.add("메모 수정");
        if (!Objects.equals(old.getContentNo(), sc.getContentNo()))        changed.add("장소 수정");
        if (old.getCost() != newCost)
            changed.add(String.format("실제 %,d원 → %,d원", old.getCost(), newCost));
        if (old.getEstimatedCost() != sc.getEstimatedCost())
            changed.add(String.format("예상 %,d원 → %,d원", old.getEstimatedCost(), sc.getEstimatedCost()));

        String base = shorten(sc.getTitle(), 20);
        if (changed.isEmpty()) return capBytes(base, 195);
        return capBytes(base + " (" + String.join("/", changed) + ")", 195);
    }

    private String capBytes(String s, int maxBytes) {
        if (s.getBytes(java.nio.charset.StandardCharsets.UTF_8).length <= maxBytes) return s;
        int len = s.length();
        while (len > 0 && s.substring(0, len).getBytes(java.nio.charset.StandardCharsets.UTF_8).length > maxBytes - 3) {
            len--;
        }
        return s.substring(0, len) + "…";
    }

    private String shorten(String s, int max) {
        if (s == null || s.isEmpty()) return "";
        return s.length() > max ? s.substring(0, max) + "…" : s;
    }

    private String nvl(String s) { return s == null ? "" : s; }

    @Transactional
    public void removeSchedule(Long no, Long planNo, Long planGuestNo) {
        // 편집 가능 기간이 아니면 RuntimeException - 컨트롤러에서 catch 후 423 반환
        assertEditable(planNo);
        // selectSchedule 은 NOT EXISTS(DEL) 필터 적용 → 이미 삭제된 일정이면 null
        ScheduleVo sc = itineraryMapper.selectSchedule(no, planNo);
        if (sc == null) return;

        // 1. "삭제" 이력 기록 - ITINERARY가 아직 존재하므로 FK 무결성 유지
        itineraryMapper.insertHistory(planNo, no, "삭제", planGuestNo,
                                      capBytes(sc.getTitle(), 195));
        // 2. TRAVEL_ITINERARY_DEL 에 소프트 삭제 마킹 (FK 없음, 영구 보존)
        itineraryMapper.insertDeleteRecord(no, planGuestNo);
        // 3. 비용 삭제 (소프트 삭제 대상 아님)
        itineraryMapper.deleteExpenseByItineraryNo(no);
        // TRAVEL_ITINERARY 는 하드 삭제하지 않음
        // - selectSchedules/selectSchedule 에서 NOT EXISTS(DEL) 필터로 제외
        // - 이력(TRAVEL_ITINERARY_HIST)은 유지되어 history 패널에 "삭제" 표시됨
    }

    public Long getPlanGuestNo(Long planNo, Long memberNo) {
        return itineraryMapper.selectPlanGuestNo(planNo, memberNo);
    }

    // 게스트 편집 권한 확인 (CAN_EDIT = 1이면 true, 0이거나 비참여자/탈퇴면 false)
    public boolean canGuestEdit(Long planNo, Long memberNo) {
        return Integer.valueOf(1).equals(itineraryMapper.selectGuestCanEdit(planNo, memberNo));
    }

    // 일정 편집 가능 기간 검사 - 불가능하면 RuntimeException 던짐
    // 편집 가능 : 여행 시작 전날까지 / 여행 종료 후 7일 이내
    // 잠금     : 여행 중 (시작일 이상 ~ 종료일 이하) / 여행 종료 후 7일 초과
    private void assertEditable(Long planNo) {
        PlanDatesVo dates = itineraryMapper.selectPlanDates(planNo);
        if (dates == null) return; // 계획 없음 → 다른 guard 에서 처리

        LocalDate start = LocalDate.parse(dates.getStartDt());
        LocalDate end   = LocalDate.parse(dates.getEndDt());
        LocalDate today = LocalDate.now();

        // 여행 중 : start <= today <= end
        boolean duringTrip = !today.isBefore(start) && !today.isAfter(end);
        // 종료 후 7일 초과 : today > end + 7
        boolean afterTrip7 = today.isAfter(end.plusDays(7));

        if (duringTrip || afterTrip7) {
            throw new RuntimeException("현재 일정을 편집할 수 없는 기간입니다.");
        }
    }

    /* -- ACTION_TYPE - 관리자 파트 -- */

    public List<ActionTypeVo> getAllActionTypes() {
        return itineraryMapper.selectAllActionTypes();
    }

    @Transactional
    public void saveActionType(String cd, String nm) {
        if (itineraryMapper.countActionType(cd) > 0) itineraryMapper.updateActionType(cd, nm);
        else itineraryMapper.insertActionType(cd, nm);
    }
}
