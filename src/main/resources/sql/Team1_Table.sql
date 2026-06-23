/*==========================================================
    Team1_Table.sql
    - TravelMate 프로젝트 전체 테이블 DDL
    - Oracle DB / FFINAL1 계정

    실행 순서:
      1. [SYS]     Team1_Table.sql      (GRANT + CREATE TABLE)
      2. [FFINAL1] Team1_Sequence.sql
      3. [FFINAL1] Team1_procedure.sql
      4. [FFINAL1] Team1_query.sql
==========================================================*/

/*----------------------------------------------------------
  [STEP 1] SYS 계정으로 먼저 실행 (주석 해제 후 실행)
  -- ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;
  -- GRANT EXECUTE ON DBMS_CRYPTO TO FFINAL1;
----------------------------------------------------------*/


/*----------------------------------------------------------
  [STEP 2] FFINAL1 계정으로 실행
----------------------------------------------------------*/


/* ─────────────────────────────────────────────
   1. ADMIN_ACCOUNT — 관리자 계정
   ───────────────────────────────────────────── */
CREATE TABLE ADMIN_ACCOUNT
(
    ADMIN_NO  NUMBER        NOT NULL,   -- 관리자 고유번호 (ADMIN_ACCOUNT_SEQ)
    ID        VARCHAR2(50)  NOT NULL,   -- 관리자 아이디
    PW        VARCHAR2(500) NOT NULL,   -- 비밀번호 (CRYPTPACK 암호화 HEX)
    CONSTRAINT PK_ADMIN_ACCOUNT    PRIMARY KEY (ADMIN_NO),
    CONSTRAINT UK_ADMIN_ACCOUNT_ID UNIQUE (ID)
);


/* ─────────────────────────────────────────────
   2. MEMBER_MASTER — 회원 기본 레코드 (PK 원천)
      회원 탈퇴 후에도 MEMBER_NO 참조를 유지하기 위해
      MEMBER_ACTIVE와 분리된 마스터 테이블
   ───────────────────────────────────────────── */
CREATE TABLE MEMBER_MASTER
(
    MEMBER_NO  NUMBER  NOT NULL,                    -- 회원 고유번호 (MEMBER_MASTER_SEQ)
    CREATE_DT  DATE    DEFAULT SYSDATE NOT NULL,    -- 가입일시
    CONSTRAINT PK_MEMBER_MASTER PRIMARY KEY (MEMBER_NO)
);


/* ─────────────────────────────────────────────
   3. MEMBER_ACTIVE — 활동 회원 상세 정보
      MEMBER_NO: MEMBER_MASTER 와 공유하는 PK + FK
      탈퇴 시 이 테이블에서만 삭제 (MEMBER_MASTER는 유지)
   ───────────────────────────────────────────── */
CREATE TABLE MEMBER_ACTIVE
(
    MEMBER_NO  NUMBER        NOT NULL,   -- 회원 고유번호 (MEMBER_MASTER.MEMBER_NO 공유)
    NAME       VARCHAR2(100) NOT NULL,   -- 이름
    NICKNAME   VARCHAR2(100) NOT NULL,   -- 닉네임 (서비스 표시용)
    ID         VARCHAR2(50)  NOT NULL,   -- 로그인 아이디
    PW         VARCHAR2(500) NOT NULL,   -- 비밀번호 (CRYPTPACK 암호화 HEX)
    EMAIL      VARCHAR2(200),            -- 이메일
    PHONE_NO   VARCHAR2(20),             -- 휴대폰번호 (예: 010-1234-5678)
    CONSTRAINT PK_MEMBER_ACTIVE          PRIMARY KEY (MEMBER_NO),
    CONSTRAINT FK_MEMBER_ACTIVE_MASTER   FOREIGN KEY (MEMBER_NO)
        REFERENCES MEMBER_MASTER(MEMBER_NO),
    CONSTRAINT UK_MEMBER_ACTIVE_ID       UNIQUE (ID),
    CONSTRAINT UK_MEMBER_ACTIVE_NICKNAME UNIQUE (NICKNAME)
);


/* ─────────────────────────────────────────────
   4. MEMBER_LEAVE — 탈퇴 회원 이력 (아카이브)
      FK 없음: 탈퇴 이력은 영구 보존 목적
      MEMBER_ACTIVE 데이터를 SELECT-INSERT로 복사
   ───────────────────────────────────────────── */
CREATE TABLE MEMBER_LEAVE
(
    MEMBER_NO  NUMBER        NOT NULL,   -- 회원 고유번호
    NAME       VARCHAR2(100),            -- 이름
    NICKNAME   VARCHAR2(100),            -- 닉네임
    ID         VARCHAR2(50),             -- 로그인 아이디
    PW         VARCHAR2(500),            -- 비밀번호 (암호화 HEX)
    EMAIL      VARCHAR2(200),            -- 이메일
    PHONE_NO   VARCHAR2(20),             -- 휴대폰번호
    LEAVE_DT   DATE DEFAULT SYSDATE,     -- 탈퇴일시
    CONSTRAINT PK_MEMBER_LEAVE PRIMARY KEY (MEMBER_NO)
);


/* ─────────────────────────────────────────────
   5. MEMBER_SANCTION — 회원 제재 이력
      FK 없음: 관리자·회원 삭제 후에도 이력 보존
      SANCTION_UNTIL = SANCTION_DT + LEVEL_DAYS
   ───────────────────────────────────────────── */
CREATE TABLE MEMBER_SANCTION
(
    SANCTION_NO    NUMBER        NOT NULL,              -- 제재 고유번호 (MEMBER_SANCTION_SEQ)
    MEMBER_NO      NUMBER        NOT NULL,              -- 제재 대상 회원번호
    LEVEL_DAYS     NUMBER        NOT NULL,              -- 제재 일수 (1 / 3 / 7)
    REASON         VARCHAR2(100),                       -- 제재 사유 코드/구분
    COMMENT        VARCHAR2(500),                       -- 제재 상세 메모
    ADMIN_NO       NUMBER,                              -- 처리 관리자번호
    SANCTION_DT    DATE          DEFAULT SYSDATE NOT NULL,  -- 제재 시작일시
    SANCTION_UNTIL DATE,                                -- 제재 해제일시 (SANCTION_DT + LEVEL_DAYS)
    CONSTRAINT PK_MEMBER_SANCTION PRIMARY KEY (SANCTION_NO)
);


/* ─────────────────────────────────────────────
   6. CONTENTCATEGORY — 관광 컨텐츠 카테고리
      한국관광공사 API 카테고리 코드 기반
      12:관광지 / 14:문화시설 / 15:축제공연행사
      25:여행코스 / 28:레포츠 / 32:숙박 / 38:쇼핑 / 39:음식점
   ───────────────────────────────────────────── */
CREATE TABLE CONTENTCATEGORY
(
    CONTENTTYPEID  VARCHAR2(20)  NOT NULL,   -- 카테고리 코드 (한국관광공사 API 기준)
    CONTENTDIV     VARCHAR2(100),            -- 카테고리명 (예: 관광지, 숙박, 음식점)
    CONSTRAINT PK_CONTENTCATEGORY PRIMARY KEY (CONTENTTYPEID)
);


/* ─────────────────────────────────────────────
   7. CONTENT — 관광 컨텐츠
      한국관광공사 API 데이터를 CSV로 임포트한 테이블
      FIRSTIMAGE / FIRSTIMAGE2: 대표이미지 URL
      MAPX / MAPY: 경도 / 위도
   ───────────────────────────────────────────── */
CREATE TABLE CONTENT
(
    CONTENTID      NUMBER           NOT NULL,   -- 컨텐츠 고유번호 (SEQ_CONTENTID)
    TITLE          VARCHAR2(500),               -- 컨텐츠명 (관광지명 등)
    ADDR1          VARCHAR2(1000),              -- 주소
    ADDR2          VARCHAR2(1000),              -- 상세주소
    CONTENTTYPEID  VARCHAR2(20),               -- 카테고리 코드 (CONTENTCATEGORY.CONTENTTYPEID)
    FIRSTIMAGE     VARCHAR2(1000),              -- 대표이미지1 URL
    FIRSTIMAGE2    VARCHAR2(1000),              -- 대표이미지2 URL
    CREATEDTIME    VARCHAR2(14),                -- API 데이터 생성일자 (yyyyMMddHHmmss)
    MODIFIEDTIME   VARCHAR2(14),                -- API 데이터 수정일자 (yyyyMMddHHmmss)
    MAPX           NUMBER(20, 15),              -- 경도
    MAPY           NUMBER(20, 15),              -- 위도
    APIID          VARCHAR2(1000),              -- 한국관광공사 API 원본 CONTENTID
    CONSTRAINT PK_CONTENT     PRIMARY KEY (CONTENTID),
    CONSTRAINT FK_CONTENT_CAT FOREIGN KEY (CONTENTTYPEID)
        REFERENCES CONTENTCATEGORY(CONTENTTYPEID)
);


/* ─────────────────────────────────────────────
   8. CONTENTEVENT — 행사/축제 일정 (CONTENT와 1:1)
      CONTENTTYPEID='15'(축제공연행사) 컨텐츠에만 존재
   ───────────────────────────────────────────── */
CREATE TABLE CONTENTEVENT
(
    CONTENTID       NUMBER       NOT NULL,   -- 컨텐츠 고유번호 (CONTENT.CONTENTID)
    EVENTSTARTDATE  VARCHAR2(20),            -- 행사 시작일 (YYYY-MM-DD)
    EVENTENDDATE    VARCHAR2(20),            -- 행사 종료일 (YYYY-MM-DD)
    CONSTRAINT PK_CONTENTEVENT      PRIMARY KEY (CONTENTID),
    CONSTRAINT FK_CONTENTEVENT_CONT FOREIGN KEY (CONTENTID)
        REFERENCES CONTENT(CONTENTID)
);


/* ─────────────────────────────────────────────
   9. IMAGE — 컨텐츠 이미지
      초기 API 데이터 로딩 시 사용
      실제 서비스는 CONTENT.FIRSTIMAGE / FIRSTIMAGE2 컬럼 사용
   ───────────────────────────────────────────── */
CREATE TABLE IMAGE
(
    CONTENTIMAGEID  NUMBER         NOT NULL,   -- 이미지 고유번호 (SEQ_CONTENTIMAGEID)
    CONTENTID       NUMBER,                    -- 컨텐츠 고유번호 (CONTENT.CONTENTID)
    IMAGE           VARCHAR2(1000),            -- 이미지 URL
    CONSTRAINT PK_CONTENTIMAGEID PRIMARY KEY (CONTENTIMAGEID),
    CONSTRAINT FK_IMAGE_CONTENT  FOREIGN KEY (CONTENTID)
        REFERENCES CONTENT(CONTENTID)
);


/* ─────────────────────────────────────────────
   10. CONTENT_REVIEW — 컨텐츠 리뷰
       MEMBER_NO → MEMBER_MASTER 참조
       (탈퇴 후에도 리뷰 보존, MEMBER_ACTIVE 삭제 무관)
       RATING: 1~5점 CHECK 제약
   ───────────────────────────────────────────── */
CREATE TABLE CONTENT_REVIEW
(
    CONTENT_REVIEW_NO  NUMBER        NOT NULL,   -- 리뷰 고유번호 (CONTENT_REVIEW_SEQ)
    MEMBER_NO          NUMBER        NOT NULL,   -- 작성 회원번호 (MEMBER_MASTER.MEMBER_NO)
    CONTENTID          NUMBER        NOT NULL,   -- 컨텐츠 고유번호 (CONTENT.CONTENTID)
    REVIEW_COMMENT     VARCHAR2(2000),           -- 리뷰 내용
    RATING             NUMBER,                  -- 별점 (1~5)
    CREATE_DT          DATE DEFAULT SYSDATE,    -- 작성일시
    CONSTRAINT PK_CONTENT_REVIEW  PRIMARY KEY (CONTENT_REVIEW_NO),
    CONSTRAINT FK_REVIEW_MEMBER   FOREIGN KEY (MEMBER_NO)
        REFERENCES MEMBER_MASTER(MEMBER_NO),
    CONSTRAINT FK_REVIEW_CONTENT  FOREIGN KEY (CONTENTID)
        REFERENCES CONTENT(CONTENTID),
    CONSTRAINT CHK_REVIEW_RATING  CHECK (RATING BETWEEN 1 AND 5)
);


/* ─────────────────────────────────────────────
   11. MEMBER_BOOKMARK — 즐겨찾기
       동일 회원이 같은 컨텐츠를 중복 즐겨찾기 방지
       → (MEMBER_NO, CONTENTID) UNIQUE 제약
   ───────────────────────────────────────────── */
CREATE TABLE MEMBER_BOOKMARK
(
    BOOKMARK_NO  NUMBER  NOT NULL,          -- 즐겨찾기 고유번호 (MEMBER_BOOKMARK_SEQ)
    MEMBER_NO    NUMBER  NOT NULL,          -- 회원 고유번호 (MEMBER_MASTER.MEMBER_NO)
    CONTENTID    NUMBER  NOT NULL,          -- 컨텐츠 고유번호 (CONTENT.CONTENTID)
    CREATE_DT    DATE    DEFAULT SYSDATE,   -- 즐겨찾기 등록일시
    CONSTRAINT PK_MEMBER_BOOKMARK      PRIMARY KEY (BOOKMARK_NO),
    CONSTRAINT FK_BOOKMARK_MEMBER      FOREIGN KEY (MEMBER_NO)
        REFERENCES MEMBER_MASTER(MEMBER_NO),
    CONSTRAINT FK_BOOKMARK_CONTENT     FOREIGN KEY (CONTENTID)
        REFERENCES CONTENT(CONTENTID),
    CONSTRAINT UK_BOOKMARK_MEMBER_CONT UNIQUE (MEMBER_NO, CONTENTID)
);


/* ─────────────────────────────────────────────
   12. NOTICE — 공지사항
       VIEW_CNT : 조회 시마다 +1 (기본값 0)
       CREATE_DT, VIEW_CNT: INSERT 시 생략 → DEFAULT 처리
   ───────────────────────────────────────────── */
CREATE TABLE NOTICE
(
    NOTICE_NO       NUMBER         NOT NULL,          -- 공지사항 고유번호 (NOTICE_SEQ)
    ADMIN_NO        NUMBER,                           -- 작성 관리자번호 (ADMIN_ACCOUNT.ADMIN_NO)
    NOTICE_TITLE    VARCHAR2(200)  NOT NULL,          -- 공지 제목
    NOTICE_CONTENT  VARCHAR2(4000),                   -- 공지 내용
    VIEW_CNT        NUMBER         DEFAULT 0,         -- 조회수
    CREATE_DT       DATE           DEFAULT SYSDATE,   -- 작성일시
    CONSTRAINT PK_NOTICE       PRIMARY KEY (NOTICE_NO),
    CONSTRAINT FK_NOTICE_ADMIN FOREIGN KEY (ADMIN_NO)
        REFERENCES ADMIN_ACCOUNT(ADMIN_NO)
);


/* ─────────────────────────────────────────────
   13. FAQ_TYPE — FAQ 카테고리
       관리자 화면에서 코드/이름을 직접 관리
   ───────────────────────────────────────────── */
CREATE TABLE FAQ_TYPE
(
    FAQ_TYPE_CD  VARCHAR2(20)  NOT NULL,   -- 카테고리 코드 (예: FT001)
    FAQ_TYPE_NM  VARCHAR2(100) NOT NULL,   -- 카테고리명 (예: 회원/계정)
    CONSTRAINT PK_FAQ_TYPE PRIMARY KEY (FAQ_TYPE_CD)
);


/* ─────────────────────────────────────────────
   14. FAQ — 자주 묻는 질문
       CREATE_DT: INSERT 시 생략 → DEFAULT SYSDATE
   ───────────────────────────────────────────── */
CREATE TABLE FAQ
(
    FAQ_NO        NUMBER         NOT NULL,          -- FAQ 고유번호 (FAQ_SEQ)
    FAQ_TYPE_CD   VARCHAR2(20)   NOT NULL,          -- 카테고리 코드 (FAQ_TYPE.FAQ_TYPE_CD)
    ADMIN_NO      NUMBER,                           -- 작성 관리자번호 (ADMIN_ACCOUNT.ADMIN_NO)
    FAQ_QUESTION  VARCHAR2(500)  NOT NULL,          -- 질문 내용
    FAQ_ANSWER    VARCHAR2(4000),                   -- 답변 내용
    CREATE_DT     DATE           DEFAULT SYSDATE,   -- 작성일시
    CONSTRAINT PK_FAQ       PRIMARY KEY (FAQ_NO),
    CONSTRAINT FK_FAQ_TYPE  FOREIGN KEY (FAQ_TYPE_CD)
        REFERENCES FAQ_TYPE(FAQ_TYPE_CD),
    CONSTRAINT FK_FAQ_ADMIN FOREIGN KEY (ADMIN_NO)
        REFERENCES ADMIN_ACCOUNT(ADMIN_NO)
);


/* ─────────────────────────────────────────────
   15. QNA_TYPE — 문의 카테고리
       관리자 화면에서 코드/이름을 직접 관리
   ───────────────────────────────────────────── */
CREATE TABLE QNA_TYPE
(
    QNA_TYPE_CD  VARCHAR2(20)  NOT NULL,   -- 카테고리 코드 (예: QT001)
    QNA_TYPE_NM  VARCHAR2(100) NOT NULL,   -- 카테고리명 (예: 회원/계정)
    CONSTRAINT PK_QNA_TYPE PRIMARY KEY (QNA_TYPE_CD)
);


/* ─────────────────────────────────────────────
   16. QNA_QUESTION — 문의 질문
       STATUS_CD: 'ST001'(접수/대기) / 'ST002'(답변완료)
       INSERT 시 STATUS_CD 생략 → DEFAULT 'ST001' 자동 설정
   ───────────────────────────────────────────── */
CREATE TABLE QNA_QUESTION
(
    QNA_REQ_NO   NUMBER         NOT NULL,                   -- 문의 고유번호 (QNA_QUESTION_SEQ)
    MEMBER_NO    NUMBER         NOT NULL,                   -- 문의 회원번호 (MEMBER_MASTER.MEMBER_NO)
    QNA_TYPE_CD  VARCHAR2(20)   NOT NULL,                   -- 카테고리 코드 (QNA_TYPE.QNA_TYPE_CD)
    QNA_TITLE    VARCHAR2(200)  NOT NULL,                   -- 문의 제목
    QNA_CONTENT  VARCHAR2(4000),                            -- 문의 내용
    STATUS_CD    VARCHAR2(10)   DEFAULT 'ST001' NOT NULL,   -- 처리상태 (ST001:접수대기, ST002:답변완료)
    CREATE_DT    DATE           DEFAULT SYSDATE,            -- 문의 등록일시
    CONSTRAINT PK_QNA_QUESTION  PRIMARY KEY (QNA_REQ_NO),
    CONSTRAINT FK_QNA_Q_MEMBER  FOREIGN KEY (MEMBER_NO)
        REFERENCES MEMBER_MASTER(MEMBER_NO),
    CONSTRAINT FK_QNA_Q_TYPE    FOREIGN KEY (QNA_TYPE_CD)
        REFERENCES QNA_TYPE(QNA_TYPE_CD),
    CONSTRAINT CHK_QNA_STATUS   CHECK (STATUS_CD IN ('ST001', 'ST002'))
);


/* ─────────────────────────────────────────────
   17. QNA_ANSWER — 문의 답변
       QNA_REQ_NO: UNIQUE → 문의 1건당 답변 1건
       답변 등록 시 QNA_QUESTION.STATUS_CD = 'ST002' 로 갱신
   ───────────────────────────────────────────── */
CREATE TABLE QNA_ANSWER
(
    QNA_ANS_NO   NUMBER         NOT NULL,   -- 답변 고유번호 (QNA_ANSWER_SEQ)
    QNA_REQ_NO   NUMBER         NOT NULL,   -- 문의 고유번호 (QNA_QUESTION.QNA_REQ_NO)
    ADMIN_NO     NUMBER,                    -- 답변 관리자번호 (ADMIN_ACCOUNT.ADMIN_NO)
    ANS_CONTENT  VARCHAR2(4000),            -- 답변 내용
    CONSTRAINT PK_QNA_ANSWER      PRIMARY KEY (QNA_ANS_NO),
    CONSTRAINT UK_QNA_ANSWER_REQ  UNIQUE (QNA_REQ_NO),
    CONSTRAINT FK_QNA_A_QUESTION  FOREIGN KEY (QNA_REQ_NO)
        REFERENCES QNA_QUESTION(QNA_REQ_NO),
    CONSTRAINT FK_QNA_A_ADMIN     FOREIGN KEY (ADMIN_NO)
        REFERENCES ADMIN_ACCOUNT(ADMIN_NO)
);


/* ─────────────────────────────────────────────
   18. TRAVEL_THEME — 여행 테마 코드 테이블
       관리자 화면에서 코드/이름을 직접 관리
   ───────────────────────────────────────────── */
CREATE TABLE TRAVEL_THEME
(
    TRAVEL_THEME_CD  VARCHAR2(20)  NOT NULL,   -- 테마 코드 (예: TH001)
    TRAVEL_THEME_NM  VARCHAR2(100) NOT NULL,   -- 테마명 (예: 힐링, 액티비티)
    CONSTRAINT PK_TRAVEL_THEME PRIMARY KEY (TRAVEL_THEME_CD)
);


/* ─────────────────────────────────────────────
   19. TRAVEL_PLAN — 여행 계획
       ROOT_TRAVEL_PLAN_NO: 버전 관리용 자기참조
         NULL 또는 자기 자신 PK = 루트(최초) 계획
       REVISION_DT: 계획 수정 시 SYSDATE 로 갱신
   ───────────────────────────────────────────── */
CREATE TABLE TRAVEL_PLAN
(
    TRAVEL_PLAN_NO      NUMBER        NOT NULL,          -- 여행계획 고유번호 (TRAVEL_PLAN_SEQ)
    HOST_MEMBER_NO      NUMBER        NOT NULL,          -- 호스트 회원번호 (MEMBER_MASTER.MEMBER_NO)
    TRAVEL_NAME         VARCHAR2(200) NOT NULL,          -- 여행계획 이름
    TRAVEL_THEME_CD     VARCHAR2(20),                    -- 여행 테마 코드 (TRAVEL_THEME.TRAVEL_THEME_CD)
    TRAVEL_START_DT     DATE,                            -- 여행 시작일
    TRAVEL_END_DT       DATE,                            -- 여행 종료일
    OUTLINE             VARCHAR2(1000),                  -- 여행 개요
    ROOT_TRAVEL_PLAN_NO NUMBER,                          -- 루트 계획 번호 (버전 분기용 자기참조)
    REVISION_DT         DATE          DEFAULT SYSDATE,   -- 최근 수정일시
    CONSTRAINT PK_TRAVEL_PLAN  PRIMARY KEY (TRAVEL_PLAN_NO),
    CONSTRAINT FK_PLAN_HOST    FOREIGN KEY (HOST_MEMBER_NO)
        REFERENCES MEMBER_MASTER(MEMBER_NO),
    CONSTRAINT FK_PLAN_THEME   FOREIGN KEY (TRAVEL_THEME_CD)
        REFERENCES TRAVEL_THEME(TRAVEL_THEME_CD)
);


/* ─────────────────────────────────────────────
   20. ACTION_TYPE — 일정 이력 액션 타입 코드
       Act001:생성 / Act002:수정 / Act003:삭제
       코드값은 DB에서 이름으로 조회하여 사용
       (앱 코드에 하드코딩 없음 — itineraryMapper.xml 참고)
   ───────────────────────────────────────────── */
CREATE TABLE ACTION_TYPE
(
    ACTION_TYPE_CD  VARCHAR2(20)  NOT NULL,   -- 액션 코드 (예: Act001)
    ACTION_TYPE_NM  VARCHAR2(100) NOT NULL,   -- 액션명 (생성 / 수정 / 삭제)
    CONSTRAINT PK_ACTION_TYPE PRIMARY KEY (ACTION_TYPE_CD)
);


/* ─────────────────────────────────────────────
   21. PLAN_GUEST — 여행 계획 참여 게스트
       호스트도 계획 생성 시 PLAN_GUEST 에 등록됨
       CREATE_DT: INSERT 시 생략 → DEFAULT SYSDATE
   ───────────────────────────────────────────── */
CREATE TABLE PLAN_GUEST
(
    PLAN_GUEST_NO   NUMBER  NOT NULL,          -- 게스트 고유번호 (PLAN_GUEST_SEQ)
    TRAVEL_PLAN_NO  NUMBER  NOT NULL,          -- 여행계획 고유번호 (TRAVEL_PLAN.TRAVEL_PLAN_NO)
    MEMBER_NO       NUMBER  NOT NULL,          -- 참여 회원번호 (MEMBER_MASTER.MEMBER_NO)
    CREATE_DT       DATE    DEFAULT SYSDATE,   -- 참여일시
    CONSTRAINT PK_PLAN_GUEST    PRIMARY KEY (PLAN_GUEST_NO),
    CONSTRAINT FK_GUEST_PLAN    FOREIGN KEY (TRAVEL_PLAN_NO)
        REFERENCES TRAVEL_PLAN(TRAVEL_PLAN_NO),
    CONSTRAINT FK_GUEST_MEMBER  FOREIGN KEY (MEMBER_NO)
        REFERENCES MEMBER_MASTER(MEMBER_NO)
);


/* ─────────────────────────────────────────────
   22. TRAVEL_ITINERARY — 여행 일정 카드
       ITINERARY_TIME: 'HH:MI' 형식 문자열 (NULL 허용)
       CONTENT_NO: 연결된 관광지 (NULL = 관광지 미연결)
   ───────────────────────────────────────────── */
CREATE TABLE TRAVEL_ITINERARY
(
    TRAVEL_ITINERARY_NO  NUMBER        NOT NULL,   -- 일정 고유번호 (TRAVEL_ITINERARY_SEQ)
    TRAVEL_PLAN_NO       NUMBER        NOT NULL,   -- 여행계획 고유번호 (TRAVEL_PLAN.TRAVEL_PLAN_NO)
    ITINERARY_DT         DATE          NOT NULL,   -- 일정 날짜
    ITINERARY_TIME       VARCHAR2(5),              -- 일정 시간 (HH:MI, 예: 09:30)
    ITINERARY_NM         VARCHAR2(200) NOT NULL,   -- 일정 제목
    ITINERARY_MEMO       VARCHAR2(1000),            -- 일정 메모
    CONTENT_NO           NUMBER,                   -- 연결 관광지 번호 (CONTENT.CONTENTID, NULL 허용)
    CONSTRAINT PK_TRAVEL_ITINERARY   PRIMARY KEY (TRAVEL_ITINERARY_NO),
    CONSTRAINT FK_ITINERARY_PLAN     FOREIGN KEY (TRAVEL_PLAN_NO)
        REFERENCES TRAVEL_PLAN(TRAVEL_PLAN_NO),
    CONSTRAINT FK_ITINERARY_CONTENT  FOREIGN KEY (CONTENT_NO)
        REFERENCES CONTENT(CONTENTID)
);


/* ─────────────────────────────────────────────
   23. ITINERARY_EXPENSE_TYPE — 비용 카테고리
       EXT001:숙박 / EXT002:교통 / EXT003:식비
       EXT004:관광/체험 / EXT005:쇼핑 / EXT006:기타
   ───────────────────────────────────────────── */
CREATE TABLE ITINERARY_EXPENSE_TYPE
(
    EXPENSE_TYPE_CD  VARCHAR2(20)  NOT NULL,   -- 비용 카테고리 코드 (예: EXT001)
    EXPENSE_TYPE_NM  VARCHAR2(100) NOT NULL,   -- 비용 카테고리명 (예: 숙박)
    CONSTRAINT PK_EXPENSE_TYPE PRIMARY KEY (EXPENSE_TYPE_CD)
);


/* ─────────────────────────────────────────────
   24. ITINERARY_EXPENSE — 일정별 비용
       ITINERARY_EXPENSE_TYPE 컬럼: 비용 카테고리 코드
         (컬럼명이 참조 테이블명과 동일 — mapper 그대로 사용)
   ───────────────────────────────────────────── */
CREATE TABLE ITINERARY_EXPENSE
(
    ITINERARY_EXPENSE_NO    NUMBER       NOT NULL,   -- 비용 고유번호 (ITINERARY_EXPENSE_SEQ)
    TRAVEL_ITINERARY_NO     NUMBER       NOT NULL,   -- 일정 고유번호 (TRAVEL_ITINERARY.TRAVEL_ITINERARY_NO)
    EXPENSE_AMT             NUMBER       NOT NULL,   -- 비용 금액 (원 단위)
    ITINERARY_EXPENSE_TYPE  VARCHAR2(20),            -- 비용 카테고리 코드 (ITINERARY_EXPENSE_TYPE.EXPENSE_TYPE_CD)
    CONSTRAINT PK_ITINERARY_EXPENSE  PRIMARY KEY (ITINERARY_EXPENSE_NO),
    CONSTRAINT FK_EXPENSE_ITINERARY  FOREIGN KEY (TRAVEL_ITINERARY_NO)
        REFERENCES TRAVEL_ITINERARY(TRAVEL_ITINERARY_NO),
    CONSTRAINT FK_EXPENSE_TYPE       FOREIGN KEY (ITINERARY_EXPENSE_TYPE)
        REFERENCES ITINERARY_EXPENSE_TYPE(EXPENSE_TYPE_CD)
);


/* ─────────────────────────────────────────────
   25. TRAVEL_ITINERARY_HIST — 일정 편집 이력
       PLAN_GUEST_NO: NULL 허용 (jdbcType=NUMERIC 처리)
         게스트 탈퇴/내보내기 후에도 이력 보존 위해 FK만
       EDIT_DT: INSERT 시 생략 → DEFAULT SYSDATE
   ───────────────────────────────────────────── */
CREATE TABLE TRAVEL_ITINERARY_HIST
(
    ITINERARY_HIST_NO    NUMBER        NOT NULL,          -- 이력 고유번호 (TRAVEL_ITINERARY_HIST_SEQ)
    TRAVEL_ITINERARY_NO  NUMBER        NOT NULL,          -- 일정 고유번호 (TRAVEL_ITINERARY.TRAVEL_ITINERARY_NO)
    ACTION_TYPE_CD       VARCHAR2(20),                    -- 액션 코드 (ACTION_TYPE.ACTION_TYPE_CD)
    PLAN_GUEST_NO        NUMBER,                          -- 편집한 게스트번호 (PLAN_GUEST.PLAN_GUEST_NO, NULL 허용)
    ITINERARY_NM         VARCHAR2(200),                   -- 편집 당시 일정 제목 (스냅샷)
    EDIT_DT              DATE          DEFAULT SYSDATE,   -- 편집일시
    CONSTRAINT PK_ITINERARY_HIST  PRIMARY KEY (ITINERARY_HIST_NO),
    CONSTRAINT FK_HIST_ITINERARY  FOREIGN KEY (TRAVEL_ITINERARY_NO)
        REFERENCES TRAVEL_ITINERARY(TRAVEL_ITINERARY_NO),
    CONSTRAINT FK_HIST_ACTION     FOREIGN KEY (ACTION_TYPE_CD)
        REFERENCES ACTION_TYPE(ACTION_TYPE_CD),
    CONSTRAINT FK_HIST_GUEST      FOREIGN KEY (PLAN_GUEST_NO)
        REFERENCES PLAN_GUEST(PLAN_GUEST_NO)
);


/* ─────────────────────────────────────────────
   26. TRAVEL_INVITATION — 초대 코드
       INVITE_CODE: UUID 문자열 (자바에서 UUID.randomUUID())
       CREATE_DT: INSERT 시 생략 → DEFAULT SYSDATE
       최신 코드 조회: ORDER BY CREATE_DT DESC + ROWNUM=1
   ───────────────────────────────────────────── */
CREATE TABLE TRAVEL_INVITATION
(
    TRAVEL_INVITATION_NO  NUMBER        NOT NULL,          -- 초대코드 고유번호 (TRAVEL_INVITATION_SEQ)
    INVITE_CODE           VARCHAR2(100) NOT NULL,          -- UUID 초대 코드
    TRAVEL_PLAN_NO        NUMBER        NOT NULL,          -- 여행계획 고유번호 (TRAVEL_PLAN.TRAVEL_PLAN_NO)
    CREATE_DT             DATE          DEFAULT SYSDATE,   -- 초대코드 생성일시
    CONSTRAINT PK_TRAVEL_INVITATION   PRIMARY KEY (TRAVEL_INVITATION_NO),
    CONSTRAINT UK_TRAVEL_INVITE_CODE  UNIQUE (INVITE_CODE),
    CONSTRAINT FK_INVITATION_PLAN     FOREIGN KEY (TRAVEL_PLAN_NO)
        REFERENCES TRAVEL_PLAN(TRAVEL_PLAN_NO)
);


/* ─────────────────────────────────────────────
   27. PLAN_GUEST_LEAVE — 게스트 탈퇴/내보내기 이력
       PLAN_GUEST_NO: PK (게스트 1명 = 탈퇴 1건)
       LEAVE_TYPE: 'leave'(자발적 탈퇴) / 'kick'(호스트 강제 내보내기)
       이 테이블에 레코드가 있으면 해당 게스트는 탈퇴 처리
   ───────────────────────────────────────────── */
CREATE TABLE PLAN_GUEST_LEAVE
(
    PLAN_GUEST_NO  NUMBER       NOT NULL,          -- 게스트 고유번호 (PLAN_GUEST.PLAN_GUEST_NO)
    LEAVE_DATE     DATE         DEFAULT SYSDATE,   -- 탈퇴/내보내기 일시
    LEAVE_TYPE     VARCHAR2(20),                   -- 탈퇴 유형 (leave: 자발적, kick: 강제)
    CONSTRAINT PK_PLAN_GUEST_LEAVE  PRIMARY KEY (PLAN_GUEST_NO),
    CONSTRAINT FK_LEAVE_GUEST       FOREIGN KEY (PLAN_GUEST_NO)
        REFERENCES PLAN_GUEST(PLAN_GUEST_NO)
);
