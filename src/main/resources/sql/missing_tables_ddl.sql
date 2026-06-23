/*===============================================
    missing_tables_ddl.sql
    - SQL 파일에 누락된 테이블 DDL
    - FFINAL1 계정으로 실행
    - db_setup.sql 실행 후 실행할 것
===============================================*/


/* ─────────────────────────────────────────────
   1. CONTENT.APIID UNIQUE 제약
      CONTENTIMAGE FK 가 CONTENT.APIID 를 참조하므로 필요
   ───────────────────────────────────────────── */
BEGIN EXECUTE IMMEDIATE 'ALTER TABLE CONTENT ADD CONSTRAINT UK_CONTENT_APIID UNIQUE (APIID)';
EXCEPTION WHEN OTHERS THEN NULL; END;
/


/* ─────────────────────────────────────────────
   2. CONTENTIMAGE — 컨텐츠 이미지
      contentMapper.xml 의 selectContentImages 에서 참조
      컬럼: CONTENTIMAGEID / APIID / ORIGINIMGURL / IMGNAME
   ───────────────────────────────────────────── */
CREATE SEQUENCE SEQ_CONTENTIMAGEID START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE NOCACHE;

BEGIN EXECUTE IMMEDIATE '
    CREATE TABLE CONTENTIMAGE (
        CONTENTIMAGEID  NUMBER          NOT NULL,
        APIID           VARCHAR2(1000),
        ORIGINIMGURL    VARCHAR2(1000),
        IMGNAME         VARCHAR2(500),
        CONSTRAINT PK_CONTENTIMAGE          PRIMARY KEY (CONTENTIMAGEID),
        CONSTRAINT FK_CONTENTIMAGE_APIID    FOREIGN KEY (APIID)
            REFERENCES CONTENT(APIID)
    )
'; EXCEPTION WHEN OTHERS THEN NULL; END;
/


/* ─────────────────────────────────────────────
   3. REVIEW_REPORT_TYPE — 리뷰 신고 타입
      reviewReportMapper.xml 의 selectReviewReportType 에서 참조
      REPORT_TYPE_CD: NUMBER (ReviewReportTypeVO.reportTypeCd → Long)
   ───────────────────────────────────────────── */
CREATE SEQUENCE REVIEW_REPORT_TYPE_SEQ START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE NOCACHE;

BEGIN EXECUTE IMMEDIATE '
    CREATE TABLE REVIEW_REPORT_TYPE (
        REPORT_TYPE_CD  NUMBER          NOT NULL,
        REPORT_TYPE_NM  VARCHAR2(100)   NOT NULL,
        CONSTRAINT PK_REVIEW_REPORT_TYPE PRIMARY KEY (REPORT_TYPE_CD)
    )
'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- 초기 신고 타입 데이터
INSERT INTO REVIEW_REPORT_TYPE (REPORT_TYPE_CD, REPORT_TYPE_NM) VALUES (REVIEW_REPORT_TYPE_SEQ.NEXTVAL, '욕설/비하');
INSERT INTO REVIEW_REPORT_TYPE (REPORT_TYPE_CD, REPORT_TYPE_NM) VALUES (REVIEW_REPORT_TYPE_SEQ.NEXTVAL, '스팸/광고');
INSERT INTO REVIEW_REPORT_TYPE (REPORT_TYPE_CD, REPORT_TYPE_NM) VALUES (REVIEW_REPORT_TYPE_SEQ.NEXTVAL, '허위 정보');
INSERT INTO REVIEW_REPORT_TYPE (REPORT_TYPE_CD, REPORT_TYPE_NM) VALUES (REVIEW_REPORT_TYPE_SEQ.NEXTVAL, '기타');


/* ─────────────────────────────────────────────
   4. REVIEW_REPORT — 리뷰 신고
      reviewReportMapper.xml 의 insertReviewReport 에서 참조
      컬럼: ReviewReportVO 필드 기반
        - REVIEW_REPORT_NO    : PK (REVIEW_REPORT_SEQ)
        - REPORTER_MEMBER_NO  : 신고자 회원번호
        - CONTENT_REVIEW_NO   : 신고 대상 리뷰번호
        - REPORT_TYPE_CD      : 신고 타입 코드 (REVIEW_REPORT_TYPE FK)
        - REPORT_COMMENT      : 신고 내용
        - REPORT_DT           : 신고 일시
        - PROCESS_YN          : 처리 여부 (Y/N)
   ───────────────────────────────────────────── */
CREATE SEQUENCE REVIEW_REPORT_SEQ START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE NOCACHE;

BEGIN EXECUTE IMMEDIATE '
    CREATE TABLE REVIEW_REPORT (
        REVIEW_REPORT_NO    NUMBER          NOT NULL,
        REPORTER_MEMBER_NO  NUMBER          NOT NULL,
        CONTENT_REVIEW_NO   NUMBER          NOT NULL,
        REPORT_TYPE_CD      NUMBER,
        REPORT_COMMENT      VARCHAR2(500),
        REPORT_DT           DATE            DEFAULT SYSDATE,
        PROCESS_YN          VARCHAR2(1)     DEFAULT ''N'',
        CONSTRAINT PK_REVIEW_REPORT         PRIMARY KEY (REVIEW_REPORT_NO),
        CONSTRAINT FK_REPORT_REVIEW         FOREIGN KEY (CONTENT_REVIEW_NO)
            REFERENCES CONTENT_REVIEW(CONTENT_REVIEW_NO),
        CONSTRAINT FK_REPORT_TYPE           FOREIGN KEY (REPORT_TYPE_CD)
            REFERENCES REVIEW_REPORT_TYPE(REPORT_TYPE_CD)
    )
'; EXCEPTION WHEN OTHERS THEN NULL; END;
/

COMMIT;
