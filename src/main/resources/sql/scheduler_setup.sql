/*===============================================
    scheduler_setup.sql
    - 한국관광공사 API 동기화 DBMS_SCHEDULER JOB 등록
    - FFINAL1 계정으로 실행

    실행 전 SYS 계정으로 한 번만 실행:
      GRANT EXECUTE ON DBMS_SCHEDULER TO FFINAL1;
      GRANT EXECUTE ON UTL_HTTP TO FFINAL1;
      GRANT EXECUTE ON DBMS_LOCK TO FFINAL1;

    실행 전 supplement_setup.sql 이 완료되어야 함:
      - P_CONTENT_API_UPSERT 프로시저 생성 확인
      - P_CONTENTIMAGE_API_UPSERT 프로시저 생성 확인
      - SYSTEM_CONFIG 에 API 키 등록 확인

    포함 JOB:
      JOB_CONTENT_UPSERT      - 매주 월요일 03:00 (CONTENT + CONTENTEVENT 동기화)
      JOB_CONTENTIMAGE_UPSERT - 매주 화요일 03:00 (CONTENTIMAGE 동기화, 전날 완료 후 실행)
===============================================*/


/* ─── JOB_CONTENT_UPSERT: 매주 월요일 03:00 ─── */

BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'JOB_CONTENT_UPSERT',
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'P_CONTENT_API_UPSERT',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=WEEKLY; BYDAY=MON; BYHOUR=3; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE,
        comments        => '한국관광공사 API 컨텐츠 데이터 주간 동기화 (매주 월요일 03:00)'
    );
END;
/


/* ─── JOB_CONTENTIMAGE_UPSERT: 매주 화요일 03:00 ─── */

BEGIN
    DBMS_SCHEDULER.CREATE_JOB(
        job_name        => 'JOB_CONTENTIMAGE_UPSERT',
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'P_CONTENTIMAGE_API_UPSERT',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=WEEKLY; BYDAY=TUE; BYHOUR=3; BYMINUTE=0; BYSECOND=0',
        enabled         => TRUE,
        comments        => '한국관광공사 API 컨텐츠 이미지 데이터 주간 동기화 (매주 화요일 03:00)'
    );
END;
/


COMMIT;
