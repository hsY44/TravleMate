/*===============================================
    dbms_scheduler.sql
    - 한국관광공사 API 데이터 동기화 Oracle 스케줄러 설정
    - FFINAL1 계정으로 실행
    - 실행 전 SYS 계정으로 UTL_HTTP 권한 부여 필요:
        GRANT EXECUTE ON UTL_HTTP TO FFINAL1;
        GRANT EXECUTE ON DBMS_SCHEDULER TO FFINAL1;

    포함 내용:
      1. SP_CONTENT_API_SYNC    - CONTENT 테이블 동기화 프로시저
      2. SP_CONTENTIMAGE_API_SYNC - IMAGE 테이블 동기화 프로시저
      3. JOB_CONTENT_API_SYNC    - 스케줄러 JOB (매주 월요일 03:00)
      4. JOB_CONTENTIMAGE_API_SYNC - 스케줄러 JOB (매주 화요일 03:00)
===============================================*/


/* ─────────────────────────────────────────────
   SP_CONTENT_API_SYNC
   - 한국관광공사 API → CONTENT 테이블 동기화
   - UTL_HTTP 로 REST API 호출 후 APEX_JSON 파싱
   - 기존 데이터는 MERGE (UPSERT) 처리
   ※ V_API_KEY 에 실제 발급받은 API 키 입력 필요
───────────────────────────────────────────── */

CREATE OR REPLACE PROCEDURE SP_CONTENT_API_SYNC
AS
    V_API_KEY   VARCHAR2(200) := 'YOUR_API_KEY_HERE';   -- 한국관광공사 API 키
    V_BASE_URL  VARCHAR2(500) := 'http://apis.data.go.kr/B551011/KorService1/areaBasedList1';
    V_URL       VARCHAR2(1000);
    V_REQ       UTL_HTTP.REQ;
    V_RESP      UTL_HTTP.RESP;
    V_BUFFER    VARCHAR2(32767);
    V_RESPONSE  CLOB           := EMPTY_CLOB();

    -- 카테고리 코드 목록 (CONTENTCATEGORY 기준)
    TYPE T_CATEGORY IS TABLE OF VARCHAR2(10) INDEX BY PLS_INTEGER;
    V_CATEGORIES T_CATEGORY;
    V_NUMROW     PLS_INTEGER;
BEGIN
    -- 카테고리 코드 설정
    V_CATEGORIES(1) := '12';   -- 관광지
    V_CATEGORIES(2) := '14';   -- 문화시설
    V_CATEGORIES(3) := '15';   -- 축제공연행사
    V_CATEGORIES(4) := '25';   -- 여행코스
    V_CATEGORIES(5) := '28';   -- 레포츠
    V_CATEGORIES(6) := '32';   -- 숙박
    V_CATEGORIES(7) := '38';   -- 쇼핑
    V_CATEGORIES(8) := '39';   -- 음식점

    -- SSL 지원 설정
    UTL_HTTP.SET_WALLET('file:/oracle/wallets/travlemate', NULL);

    FOR I IN 1 .. V_CATEGORIES.COUNT LOOP

        V_URL := V_BASE_URL
            || '?serviceKey='   || UTL_URL.ESCAPE(V_API_KEY, FALSE)
            || '&numOfRows=1000'
            || '&pageNo=1'
            || '&MobileOS=ETC'
            || '&MobileApp=TravleMate'
            || '&_type=json'
            || '&contentTypeId=' || V_CATEGORIES(I)
            || '&areaCode=&sigunguCode=&cat1=&cat2=&cat3=&mapX=&mapY=&radius=&modifiedtime=';

        -- API 호출
        V_REQ      := UTL_HTTP.BEGIN_REQUEST(V_URL, 'GET');
        V_RESP     := UTL_HTTP.GET_RESPONSE(V_REQ);
        V_RESPONSE := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_RESPONSE, TRUE);

        BEGIN
            LOOP
                UTL_HTTP.READ_TEXT(V_RESP, V_BUFFER, 32767);
                DBMS_LOB.WRITEAPPEND(V_RESPONSE, LENGTH(V_BUFFER), V_BUFFER);
            END LOOP;
        EXCEPTION
            WHEN UTL_HTTP.END_OF_BODY THEN NULL;
        END;

        UTL_HTTP.END_RESPONSE(V_RESP);

        -- JSON 파싱 후 MERGE
        APEX_JSON.PARSE(V_RESPONSE);
        V_NUMROW := APEX_JSON.GET_COUNT(P_PATH => 'response.body.items.item');

        FOR J IN 1 .. NVL(V_NUMROW, 0) LOOP
            MERGE INTO CONTENT C
            USING (
                SELECT
                    TO_NUMBER(APEX_JSON.GET_VARCHAR2(P_PATH => 'response.body.items.item[%d].contentid', P0 => J))  AS CONTENTID,
                    APEX_JSON.GET_VARCHAR2(P_PATH => 'response.body.items.item[%d].title',         P0 => J)         AS TITLE,
                    APEX_JSON.GET_VARCHAR2(P_PATH => 'response.body.items.item[%d].addr1',         P0 => J)         AS ADDR1,
                    APEX_JSON.GET_VARCHAR2(P_PATH => 'response.body.items.item[%d].addr2',         P0 => J)         AS ADDR2,
                    APEX_JSON.GET_VARCHAR2(P_PATH => 'response.body.items.item[%d].contenttypeid', P0 => J)         AS CONTENTTYPEID,
                    APEX_JSON.GET_VARCHAR2(P_PATH => 'response.body.items.item[%d].firstimage',    P0 => J)         AS FIRSTIMAGE,
                    APEX_JSON.GET_VARCHAR2(P_PATH => 'response.body.items.item[%d].firstimage2',   P0 => J)         AS FIRSTIMAGE2,
                    APEX_JSON.GET_VARCHAR2(P_PATH => 'response.body.items.item[%d].createdtime',   P0 => J)         AS CREATEDTIME,
                    APEX_JSON.GET_VARCHAR2(P_PATH => 'response.body.items.item[%d].modifiedtime',  P0 => J)         AS MODIFIEDTIME,
                    APEX_JSON.GET_NUMBER  (P_PATH => 'response.body.items.item[%d].mapx',          P0 => J)         AS MAPX,
                    APEX_JSON.GET_NUMBER  (P_PATH => 'response.body.items.item[%d].mapy',          P0 => J)         AS MAPY
                FROM DUAL
            ) S ON (C.CONTENTID = S.CONTENTID)
            WHEN MATCHED THEN
                UPDATE SET
                    C.TITLE         = S.TITLE,
                    C.ADDR1         = S.ADDR1,
                    C.ADDR2         = S.ADDR2,
                    C.FIRSTIMAGE    = S.FIRSTIMAGE,
                    C.FIRSTIMAGE2   = S.FIRSTIMAGE2,
                    C.MODIFIEDTIME  = S.MODIFIEDTIME,
                    C.MAPX          = S.MAPX,
                    C.MAPY          = S.MAPY
            WHEN NOT MATCHED THEN
                INSERT (CONTENTID, TITLE, ADDR1, ADDR2, CONTENTTYPEID,
                        FIRSTIMAGE, FIRSTIMAGE2, CREATEDTIME, MODIFIEDTIME, MAPX, MAPY)
                VALUES (S.CONTENTID, S.TITLE, S.ADDR1, S.ADDR2, S.CONTENTTYPEID,
                        S.FIRSTIMAGE, S.FIRSTIMAGE2, S.CREATEDTIME, S.MODIFIEDTIME, S.MAPX, S.MAPY);
        END LOOP;

        DBMS_LOB.FREETEMPORARY(V_RESPONSE);
        COMMIT;

    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SP_CONTENT_API_SYNC;
/


/* ─────────────────────────────────────────────
   SP_CONTENTIMAGE_API_SYNC
   - 한국관광공사 API → IMAGE 테이블 동기화
   - CONTENT 테이블에 존재하는 CONTENTID 기준으로
     detailImage1 API 호출 후 이미지 목록 MERGE
───────────────────────────────────────────── */

CREATE OR REPLACE PROCEDURE SP_CONTENTIMAGE_API_SYNC
AS
    V_API_KEY  VARCHAR2(200) := 'YOUR_API_KEY_HERE';   -- 한국관광공사 API 키
    V_BASE_URL VARCHAR2(500) := 'http://apis.data.go.kr/B551011/KorService1/detailImage1';
    V_URL      VARCHAR2(1000);
    V_REQ      UTL_HTTP.REQ;
    V_RESP     UTL_HTTP.RESP;
    V_BUFFER   VARCHAR2(32767);
    V_RESPONSE CLOB;
    V_NUMROW   PLS_INTEGER;

    -- CONTENT 테이블 전체 순회
    CURSOR C_CONTENT IS
        SELECT CONTENTID FROM CONTENT ORDER BY CONTENTID;
BEGIN
    UTL_HTTP.SET_WALLET('file:/oracle/wallets/travlemate', NULL);

    FOR REC IN C_CONTENT LOOP

        V_URL := V_BASE_URL
            || '?serviceKey='   || UTL_URL.ESCAPE(V_API_KEY, FALSE)
            || '&MobileOS=ETC'
            || '&MobileApp=TravleMate'
            || '&_type=json'
            || '&contentId='    || REC.CONTENTID
            || '&imageYN=Y'
            || '&subImageYN=Y'
            || '&numOfRows=10';

        V_REQ      := UTL_HTTP.BEGIN_REQUEST(V_URL, 'GET');
        V_RESP     := UTL_HTTP.GET_RESPONSE(V_REQ);
        V_RESPONSE := EMPTY_CLOB();
        DBMS_LOB.CREATETEMPORARY(V_RESPONSE, TRUE);

        BEGIN
            LOOP
                UTL_HTTP.READ_TEXT(V_RESP, V_BUFFER, 32767);
                DBMS_LOB.WRITEAPPEND(V_RESPONSE, LENGTH(V_BUFFER), V_BUFFER);
            END LOOP;
        EXCEPTION
            WHEN UTL_HTTP.END_OF_BODY THEN NULL;
        END;

        UTL_HTTP.END_RESPONSE(V_RESP);

        APEX_JSON.PARSE(V_RESPONSE);
        V_NUMROW := APEX_JSON.GET_COUNT(P_PATH => 'response.body.items.item');

        -- 해당 CONTENTID 의 이미지를 재동기화 (삭제 후 재삽입)
        DELETE FROM IMAGE WHERE CONTENTID = REC.CONTENTID;

        FOR J IN 1 .. NVL(V_NUMROW, 0) LOOP
            INSERT INTO IMAGE (CONTENTIMAGEID, CONTENTID, IMAGE)
            VALUES (
                SEQ_CONTENTIMAGEID.NEXTVAL,
                REC.CONTENTID,
                APEX_JSON.GET_VARCHAR2(P_PATH => 'response.body.items.item[%d].originimgurl', P0 => J)
            );
        END LOOP;

        DBMS_LOB.FREETEMPORARY(V_RESPONSE);
        COMMIT;

    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END SP_CONTENTIMAGE_API_SYNC;
/


/* ─────────────────────────────────────────────
   JOB_CONTENT_API_SYNC
   - 매주 월요일 오전 3시 실행
   - SP_CONTENT_API_SYNC 프로시저 호출
───────────────────────────────────────────── */

BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'JOB_CONTENT_API_SYNC',
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'SP_CONTENT_API_SYNC',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=WEEKLY; BYDAY=MON; BYHOUR=3; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE,
        comments        => '한국관광공사 API 컨텐츠 데이터 주간 동기화 (매주 월요일 03:00)'
    );
END;
/


/* ─────────────────────────────────────────────
   JOB_CONTENTIMAGE_API_SYNC
   - 매주 화요일 오전 3시 실행 (CONTENT 동기화 다음날)
   - SP_CONTENTIMAGE_API_SYNC 프로시저 호출
───────────────────────────────────────────── */

BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'JOB_CONTENTIMAGE_API_SYNC',
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'SP_CONTENTIMAGE_API_SYNC',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=WEEKLY; BYDAY=TUE; BYHOUR=3; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE,
        comments        => '한국관광공사 API 컨텐츠 이미지 데이터 주간 동기화 (매주 화요일 03:00)'
    );
END;
/

COMMIT;
