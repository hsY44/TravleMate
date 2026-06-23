/*==========================================================
    Team1_query.sql
    - TravelMate 프로젝트 초기 데이터 INSERT
    - Oracle DB / FFINAL1 계정

    ※ 반드시 Team1_procedure.sql 실행 후 실행
       (ADMIN_ACCOUNT.PW 삽입 시 CRYPTPACK.ENCRYPT 사용)

    실행 순서:
      1. [FFINAL1] Team1_Table.sql
      2. [FFINAL1] Team1_Sequence.sql
      3. [FFINAL1] Team1_procedure.sql  ← 먼저 실행
      4. [FFINAL1] Team1_query.sql      (현재 파일)
==========================================================*/


/* ─────────────────────────────────────────────
   1. CONTENTCATEGORY — 관광 컨텐츠 카테고리
      한국관광공사 API 카테고리 코드 기준
   ───────────────────────────────────────────── */
INSERT INTO CONTENTCATEGORY (CONTENTTYPEID, CONTENTDIV) VALUES ('12', '관광지');
INSERT INTO CONTENTCATEGORY (CONTENTTYPEID, CONTENTDIV) VALUES ('14', '문화시설');
INSERT INTO CONTENTCATEGORY (CONTENTTYPEID, CONTENTDIV) VALUES ('15', '축제공연행사');
INSERT INTO CONTENTCATEGORY (CONTENTTYPEID, CONTENTDIV) VALUES ('25', '여행코스');
INSERT INTO CONTENTCATEGORY (CONTENTTYPEID, CONTENTDIV) VALUES ('28', '레포츠');
INSERT INTO CONTENTCATEGORY (CONTENTTYPEID, CONTENTDIV) VALUES ('32', '숙박');
INSERT INTO CONTENTCATEGORY (CONTENTTYPEID, CONTENTDIV) VALUES ('38', '쇼핑');
INSERT INTO CONTENTCATEGORY (CONTENTTYPEID, CONTENTDIV) VALUES ('39', '음식점');


/* ─────────────────────────────────────────────
   2. ACTION_TYPE — 일정 이력 액션 코드
      itineraryMapper.xml 의 insertHistory 에서
      ACTION_TYPE_NM('생성'/'수정'/'삭제') 으로 코드 조회
      → 코드값 변경 시 앱 영향 없음
   ───────────────────────────────────────────── */
INSERT INTO ACTION_TYPE (ACTION_TYPE_CD, ACTION_TYPE_NM) VALUES ('Act001', '생성');
INSERT INTO ACTION_TYPE (ACTION_TYPE_CD, ACTION_TYPE_NM) VALUES ('Act002', '수정');
INSERT INTO ACTION_TYPE (ACTION_TYPE_CD, ACTION_TYPE_NM) VALUES ('Act003', '삭제');


/* ─────────────────────────────────────────────
   3. ITINERARY_EXPENSE_TYPE — 비용 카테고리
      itineraryMapper.xml insertExpense 에서
      EXPENSE_TYPE_NM 으로 코드 조회 (NVL → 기타)
   ───────────────────────────────────────────── */
INSERT INTO ITINERARY_EXPENSE_TYPE (EXPENSE_TYPE_CD, EXPENSE_TYPE_NM) VALUES ('EXT001', '숙박');
INSERT INTO ITINERARY_EXPENSE_TYPE (EXPENSE_TYPE_CD, EXPENSE_TYPE_NM) VALUES ('EXT002', '교통');
INSERT INTO ITINERARY_EXPENSE_TYPE (EXPENSE_TYPE_CD, EXPENSE_TYPE_NM) VALUES ('EXT003', '식비');
INSERT INTO ITINERARY_EXPENSE_TYPE (EXPENSE_TYPE_CD, EXPENSE_TYPE_NM) VALUES ('EXT004', '관광/체험');
INSERT INTO ITINERARY_EXPENSE_TYPE (EXPENSE_TYPE_CD, EXPENSE_TYPE_NM) VALUES ('EXT005', '쇼핑');
INSERT INTO ITINERARY_EXPENSE_TYPE (EXPENSE_TYPE_CD, EXPENSE_TYPE_NM) VALUES ('EXT006', '기타');


/* ─────────────────────────────────────────────
   4. FAQ_TYPE — FAQ 카테고리
      관리자 화면에서 추가/수정 가능
   ───────────────────────────────────────────── */
INSERT INTO FAQ_TYPE (FAQ_TYPE_CD, FAQ_TYPE_NM) VALUES ('FT001', '회원/계정');
INSERT INTO FAQ_TYPE (FAQ_TYPE_CD, FAQ_TYPE_NM) VALUES ('FT002', '여행계획');
INSERT INTO FAQ_TYPE (FAQ_TYPE_CD, FAQ_TYPE_NM) VALUES ('FT003', '서비스 이용');
INSERT INTO FAQ_TYPE (FAQ_TYPE_CD, FAQ_TYPE_NM) VALUES ('FT004', '기타');


/* ─────────────────────────────────────────────
   5. QNA_TYPE — 문의 카테고리
      관리자 화면에서 추가/수정 가능
   ───────────────────────────────────────────── */
INSERT INTO QNA_TYPE (QNA_TYPE_CD, QNA_TYPE_NM) VALUES ('QT001', '회원/계정');
INSERT INTO QNA_TYPE (QNA_TYPE_CD, QNA_TYPE_NM) VALUES ('QT002', '여행계획');
INSERT INTO QNA_TYPE (QNA_TYPE_CD, QNA_TYPE_NM) VALUES ('QT003', '서비스 이용');
INSERT INTO QNA_TYPE (QNA_TYPE_CD, QNA_TYPE_NM) VALUES ('QT004', '기타');


/* ─────────────────────────────────────────────
   6. TRAVEL_THEME — 여행 테마
      관리자 화면에서 추가/수정 가능
      travelMapper.xml insertPlan/updatePlan 에서
      TRAVEL_THEME_NM 으로 코드 조회
   ───────────────────────────────────────────── */
INSERT INTO TRAVEL_THEME (TRAVEL_THEME_CD, TRAVEL_THEME_NM) VALUES ('TH001', '힐링');
INSERT INTO TRAVEL_THEME (TRAVEL_THEME_CD, TRAVEL_THEME_NM) VALUES ('TH002', '관광/문화');
INSERT INTO TRAVEL_THEME (TRAVEL_THEME_CD, TRAVEL_THEME_NM) VALUES ('TH003', '맛집 투어');
INSERT INTO TRAVEL_THEME (TRAVEL_THEME_CD, TRAVEL_THEME_NM) VALUES ('TH004', '액티비티');
INSERT INTO TRAVEL_THEME (TRAVEL_THEME_CD, TRAVEL_THEME_NM) VALUES ('TH005', '가족 여행');
INSERT INTO TRAVEL_THEME (TRAVEL_THEME_CD, TRAVEL_THEME_NM) VALUES ('TH006', '자연/힐링');


/* ─────────────────────────────────────────────
   7. ADMIN_ACCOUNT — 초기 관리자 계정
      ※ CRYPTPACK.ENCRYPT 사용 → Team1_procedure.sql 먼저 실행 필수
      기본 계정: ID=admin / PW=admin1234
      ※ 운영 배포 전 반드시 비밀번호 변경할 것
   ───────────────────────────────────────────── */
INSERT INTO ADMIN_ACCOUNT (ADMIN_NO, ID, PW)
VALUES (
    ADMIN_ACCOUNT_SEQ.NEXTVAL,
    'admin',
    CRYPTPACK.ENCRYPT('admin1234', 'YOUR_CRYPTO_KEY_HERE')  -- application.yml 의 crypto.key 와 동일하게 입력
);


COMMIT;
