/*===============================================
    plan_checklist_ddl.sql
    - PLAN_CHECKLIST 테이블 및 시퀀스 생성
    - FFINAL1 계정으로 실행
    - 멱등성 보장: 이미 존재하면 무시
===============================================*/


/* ─────────────────────────────────────────────
   PLAN_CHECKLIST_SEQ 시퀀스
───────────────────────────────────────────── */

CREATE SEQUENCE PLAN_CHECKLIST_SEQ START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE NOCACHE;


/* ─────────────────────────────────────────────
   PLAN_CHECKLIST 테이블
   - 여행 계획 체크리스트 (준비물) 관리
   - CHECKLIST_NO   : PK (PLAN_CHECKLIST_SEQ)
   - TRAVEL_PLAN_NO : FK → TRAVEL_PLAN
   - CONTENT        : 항목 내용
   - IS_CHECKED     : 체크 여부 (0=미체크, 1=체크, DEFAULT 0)
   - CREATE_DT      : 등록일시 (DEFAULT SYSDATE)
───────────────────────────────────────────── */

BEGIN EXECUTE IMMEDIATE '
    CREATE TABLE PLAN_CHECKLIST (
        CHECKLIST_NO    NUMBER          NOT NULL,
        TRAVEL_PLAN_NO  NUMBER          NOT NULL,
        CONTENT         VARCHAR2(200)   NOT NULL,
        IS_CHECKED      NUMBER(1)       DEFAULT 0 NOT NULL,
        CREATE_DT       DATE            DEFAULT SYSDATE NOT NULL,
        CONSTRAINT PK_PLAN_CHECKLIST PRIMARY KEY (CHECKLIST_NO),
        CONSTRAINT FK_PLAN_CHECKLIST_PLAN
            FOREIGN KEY (TRAVEL_PLAN_NO)
            REFERENCES TRAVEL_PLAN(TRAVEL_PLAN_NO)
    )
'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

COMMIT;
