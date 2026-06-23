/*===============================================
    AdminService.java
    - 관리자 계정 관련 비즈니스 로직
    - AdminMapper 를 통해 DB 연동
===============================================*/
package com.doit.app.service;

import com.doit.app.domain.AdminVo;
import com.doit.app.mapper.AdminMapper;
import org.springframework.beans.factory.annotation.Value;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Slf4j
@Service
public class AdminService
{
    private final AdminMapper adminMapper;

    @Value("${crypto.key}")
    private String cryptoKey;


    // 관리자 로그인 인증
    // - encKey 를 전달하여 SQL 에서 CRYPTPACK.ENCRYPT(pw, encKey) 비교
    // 성공: AdminVo 반환 / 실패(일치 없음): null 반환
    public AdminVo login(String loginId, String pw)
    {
        return adminMapper.selectAdminLogin(loginId, pw, cryptoKey);
    }
}
