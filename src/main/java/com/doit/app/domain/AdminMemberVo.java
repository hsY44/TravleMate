/*===============================================
    AdminMemberVo.java
    - 관리자용 회원 조회 도메인 객체
    - 활동 회원(MEMBER_MASTER JOIN MEMBER_ACTIVE) 및
      탈퇴 회원(MEMBER_LEAVE) 조회 결과 매핑
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class AdminMemberVo
{
    private Long   memberNo;    // 회원 고유번호
    private String name;        // 이름
    private String nickname;    // 닉네임
    private String loginId;     // 아이디
    private String email;       // 이메일
    private String phoneNo;     // 휴대폰번호
    private String createDt;    // 가입일 (활동 회원용)
    private String leaveDt;     // 탈퇴일 (탈퇴 회원용)
}
