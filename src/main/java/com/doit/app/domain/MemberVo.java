/*===============================================
    MemberVo.java
    - 활동 회원 도메인 객체
    - MEMBER_MASTER + MEMBER_ACTIVE 테이블 매핑
    ※ DB 컬럼명과 필드명이 다른 항목
       ID       → loginId
       PHONE_NO → phoneNo
    ※ encKey : DB 컬럼 없음, CRYPTPACK SQL 함수에 키 전달 목적
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class MemberVo
{
    private Long   memberNo;    // 회원 고유번호  (MEMBER_MASTER.MEMBER_NO)
    private String name;        // 이름           (MEMBER_ACTIVE.NAME)
    private String nickname;    // 닉네임         (MEMBER_ACTIVE.NICKNAME)
    private String loginId;     // 아이디         (MEMBER_ACTIVE.ID)
    private String pw;          // 비밀번호       (MEMBER_ACTIVE.PW) - 암호화된 HEX 저장
    private String email;       // 이메일         (MEMBER_ACTIVE.EMAIL)
    private String phoneNo;     // 휴대폰번호     (MEMBER_ACTIVE.PHONE_NO)
    private String encKey;      // 암호화 키 전달용 (DB 컬럼 없음, SQL 함수 파라미터용)
}
