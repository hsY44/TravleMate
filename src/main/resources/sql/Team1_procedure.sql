/*==========================================================
    Team1_procedure.sql
    - TravelMate 프로젝트 패키지/프로시저 DDL
    - Oracle DB / FFINAL1 계정

    실행 전 SYS 계정으로 아래 권한 먼저 부여:
      ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;
      GRANT EXECUTE ON DBMS_CRYPTO TO FFINAL1;

    실행 순서:
      1. [FFINAL1] Team1_Table.sql
      2. [FFINAL1] Team1_Sequence.sql
      3. [FFINAL1] Team1_procedure.sql  (현재 파일)
      4. [FFINAL1] Team1_query.sql
==========================================================*/


/* ─────────────────────────────────────────────
   CRYPTPACK — AES256 양방향 암호화 패키지
   - Oracle DBMS_CRYPTO 기반 AES256 + CBC 모드 + PKCS5 패딩
   - ENCRYPT(평문, 키) → 16진수 암호문 반환
   - DECRYPT(암호문, 키) → 평문 반환
   - 암호화 키: application.yml 의 crypto.key 와 동일해야 함
       암호화 키: application.yml 의 crypto.key 참고
   - 사용 테이블: MEMBER_ACTIVE.PW / ADMIN_ACCOUNT.PW
   ───────────────────────────────────────────── */

-- 패키지 명세 (인터페이스 선언)
CREATE OR REPLACE PACKAGE CRYPTPACK
AS
    -- 평문을 AES256 암호화하여 HEX 문자열로 반환
    FUNCTION ENCRYPT(STR VARCHAR2, HASH VARCHAR2) RETURN VARCHAR2;

    -- HEX 암호문을 복호화하여 평문 반환
    FUNCTION DECRYPT(XCRYPT VARCHAR2, HASH VARCHAR2) RETURN VARCHAR2;
END CRYPTPACK;
/

-- 패키지 본문 (구현)
CREATE OR REPLACE PACKAGE BODY CRYPTPACK
AS
    -- 암호화 알고리즘: AES256 + CBC 모드 + PKCS5 패딩
    V_TYP CONSTANT PLS_INTEGER := DBMS_CRYPTO.ENCRYPT_AES256
                                + DBMS_CRYPTO.CHAIN_CBC
                                + DBMS_CRYPTO.PAD_PKCS5;

    /*
        ENCRYPT
        - STR  : 암호화할 평문 (회원 비밀번호 등)
        - HASH : 암호화 키 (application.yml crypto.key)
        - 키는 32바이트로 RPAD('#' 패딩) 처리
        - 반환값: RAWTOHEX 변환된 16진수 문자열 → DB에 VARCHAR2로 저장
    */
    FUNCTION ENCRYPT(STR VARCHAR2, HASH VARCHAR2)
    RETURN VARCHAR2
    IS
        V_RAW       RAW(2000);
        V_KEY_RAW   RAW(32);
        V_ENCRYPTED RAW(2000);
    BEGIN
        V_RAW       := UTL_I18N.STRING_TO_RAW(STR, 'AL32UTF8');
        V_KEY_RAW   := UTL_RAW.CAST_TO_RAW(RPAD(HASH, 32, '#'));
        V_ENCRYPTED := DBMS_CRYPTO.ENCRYPT(
            SRC => V_RAW,
            TYP => V_TYP,
            KEY => V_KEY_RAW
        );
        RETURN RAWTOHEX(V_ENCRYPTED);
    END;

    /*
        DECRYPT
        - XCRYPT : ENCRYPT 가 반환한 HEX 암호문
        - HASH   : 암호화 키 (ENCRYPT 와 동일 키여야 함)
        - 반환값 : 복호화된 평문
        - 오류 시: 'DECRYPT_ERROR' 반환 (예외 처리)
    */
    FUNCTION DECRYPT(XCRYPT VARCHAR2, HASH VARCHAR2)
    RETURN VARCHAR2
    IS
        V_DECRYPTED_RAW RAW(2000);
        V_KEY_RAW       RAW(32);
    BEGIN
        V_KEY_RAW := UTL_RAW.CAST_TO_RAW(RPAD(HASH, 32, '#'));
        V_DECRYPTED_RAW := DBMS_CRYPTO.DECRYPT(
            SRC => HEXTORAW(XCRYPT),
            TYP => V_TYP,
            KEY => V_KEY_RAW
        );
        RETURN UTL_I18N.RAW_TO_CHAR(V_DECRYPTED_RAW, 'AL32UTF8');
    EXCEPTION
        WHEN OTHERS THEN RETURN 'DECRYPT_ERROR';
    END;

END CRYPTPACK;
/
