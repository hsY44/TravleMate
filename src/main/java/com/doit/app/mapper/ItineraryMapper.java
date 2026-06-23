/*===============================================
    ItineraryMapper.java
===============================================*/
package com.doit.app.mapper;

import com.doit.app.domain.ActionTypeVo;
import com.doit.app.domain.CostSummaryVo;
import com.doit.app.domain.HistoryVo;
import com.doit.app.domain.PlanDatesVo;
import com.doit.app.domain.ScheduleVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ItineraryMapper
{
    /* 일정 */
    List<ScheduleVo> selectSchedules(@Param("planNo") Long planNo);
    ScheduleVo selectSchedule(@Param("no") Long no, @Param("planNo") Long planNo);
    void insertSchedule(ScheduleVo sc);
    void updateSchedule(ScheduleVo sc);
    void deleteSchedule(@Param("no") Long no, @Param("planNo") Long planNo);

    /* 비용 */
    void insertExpense(@Param("itineraryNo")   Long   itineraryNo,
                       @Param("amount")        long   amount,
                       @Param("estimatedAmt")  long   estimatedAmt,
                       @Param("typeName")      String typeName,
                       @Param("paymentMethod") String paymentMethod,
                       @Param("expenseMemo")   String expenseMemo);
    void deleteExpenseByItineraryNo(@Param("itineraryNo") Long itineraryNo);
    List<CostSummaryVo> selectCostSummary(@Param("planNo") Long planNo);
    long selectTotalCost(@Param("planNo") Long planNo);
    long selectTotalEstimatedCost(@Param("planNo") Long planNo);
    List<String> selectExpenseTypeNames();

    /* 삭제 이력 - TRAVEL_ITINERARY_DEL (FK 제약 없음, 영구 보존) */
    void insertDeleteRecord(@Param("itineraryNo")    Long itineraryNo,
                            @Param("deleterGuestNo") Long deleterGuestNo);

    /* 이력 - actionTypeNm("생성"/"수정"/"삭제") 으로 CD 서브쿼리 조회 */
    void insertHistory(@Param("planNo")       Long   planNo,
                       @Param("itineraryNo")  Long   itineraryNo,
                       @Param("actionTypeNm") String actionTypeNm,
                       @Param("planGuestNo")  Long   planGuestNo,
                       @Param("target")       String target);
    List<HistoryVo> selectHistory(@Param("planNo") Long planNo);

    /* 보조 조회 */
    String selectPlanStartDate(@Param("planNo") Long planNo);
    // 시작/종료일 조회 (일정 편집 잠금 판단용)
    PlanDatesVo selectPlanDates(@Param("planNo") Long planNo);
    // 활성 게스트 PLAN_GUEST_NO 조회 (탈퇴/내보내기 제외)
    Long selectPlanGuestNo(@Param("planNo") Long planNo, @Param("memberNo") Long memberNo);
    // 게스트 편집 권한 조회 (탈퇴/내보내기 제외, NULL이면 1, 비참여자면 null)
    Integer selectGuestCanEdit(@Param("planNo") Long planNo, @Param("memberNo") Long memberNo);

    /* ACTION_TYPE - 관리자 파트 */
    List<ActionTypeVo> selectAllActionTypes();
    void insertActionType(@Param("cd") String cd, @Param("nm") String nm);
    void updateActionType(@Param("cd") String cd, @Param("nm") String nm);
    int countActionType(@Param("cd") String cd);
    void deleteHistoryByItineraryNo(@Param("itineraryNo") Long itineraryNo);
}
