/*===============================================
    AdminVo.java
    - 관리자 계정 도메인 객체
    - ADMIN_ACCOUNT 테이블 매핑
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
public class AdminVo
{
    private Long   adminNo;     // 관리자 고유번호  (ADMIN_ACCOUNT.ADMIN_NO)
    private String loginId;     // 관리자 아이디    (ADMIN_ACCOUNT.ID)
    //-- 비밀번호는 세션에 저장하지 않으므로 여기선 제외
}
