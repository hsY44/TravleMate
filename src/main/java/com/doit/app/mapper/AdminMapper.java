/*===============================================
    AdminMapper.java
    - 관리자 관련 MyBatis Mapper 인터페이스
    - adminMapper.xml 과 연결
===============================================*/
package com.doit.app.mapper;

import com.doit.app.domain.AdminMemberVo;
import com.doit.app.domain.AdminVo;
import com.doit.app.domain.SanctionVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface AdminMapper
{
    // 관리자 로그인 - 아이디/암호화 비밀번호 일치 관리자 조회
    AdminVo selectAdminLogin(@Param("loginId") String loginId,
                             @Param("pw")      String pw,
                             @Param("encKey")  String encKey);

    // 활동 회원 

    // 활동 회원 수 (키워드 검색 포함)
    int countActiveMembers(@Param("keyword") String keyword);

    // 활동 회원 목록 - 키워드 검색 + 페이징
    List<AdminMemberVo> selectActiveMembers(@Param("keyword")   String keyword,
                                            @Param("startRow") int    startRow,
                                            @Param("endRow")   int    endRow);

    // 활동 회원 단건 조회
    AdminMemberVo selectActiveMemberByNo(Long memberNo);

    // 탈퇴 회원

    // 탈퇴 회원 수
    int countLeaveMembers();

    // 탈퇴 회원 목록 - 페이징
    List<AdminMemberVo> selectLeaveMembers(@Param("startRow") int startRow,
                                           @Param("endRow")   int endRow);

    // 탈퇴 회원 단건 조회
    AdminMemberVo selectLeaveMemberByNo(Long memberNo);

    // 회원 제재 이력 저장
    void insertSanction(SanctionVo vo);
}
