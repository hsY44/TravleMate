-- ============================================================
--  일정 삭제 이력 기록 지원을 위한 스키마 변경
--  적용 전 팀원 검토 필요
--
--  변경 목적:
--    현재 removeSchedule() 에서 FK 제약(FK_HIST_ITINERARY) 때문에
--    일정 삭제 전 이력을 먼저 지워야 하는 구조임.
--    → 삭제 이력이 기록되지 않고, 기존 생성/수정 이력도 함께 사라짐.
--
--    TRAVEL_PLAN_NO 컬럼 추가 + FK 제거로 이 문제를 해결함.
-- ============================================================

-- 1. TRAVEL_PLAN_NO 컬럼 추가
--    삭제된 일정의 이력도 planNo 기준으로 직접 조회 가능하게 함
--    (기존 selectHistory 는 JOIN TRAVEL_ITINERARY 로 planNo 를 걸었으나,
--     일정 삭제 후에는 해당 행이 없어 조회 불가)
ALTER TABLE TRAVEL_ITINERARY_HIST ADD TRAVEL_PLAN_NO NUMBER;

-- 2. FK_HIST_ITINERARY 제약 제거
--    일정(TRAVEL_ITINERARY) 삭제 후에도 이력 행이 남아있을 수 있게 함
--    (이력 기록 시점에는 TRAVEL_ITINERARY_NO 가 반드시 존재하므로
--     NOT NULL 은 그대로 유지)
ALTER TABLE TRAVEL_ITINERARY_HIST DROP CONSTRAINT FK_HIST_ITINERARY;
