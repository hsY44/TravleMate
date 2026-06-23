/*===============================================
    MemberService.java
    - 회원 관련 비즈니스 로직
    - MemberMapper 를 통해 DB 연동
    - 비밀번호 암호화 : Oracle CRYPTPACK.ENCRYPT (AES256)
      → application.yml 의 crypto.key 를 SQL 함수에 전달
      → 암호화/복호화는 DB(CRYPTPACK 패키지)에서 처리
===============================================*/
package com.doit.app.service;

import com.doit.app.domain.BookmarkVo;
import com.doit.app.domain.MemberVo;
import com.doit.app.domain.ReviewVo;
import com.doit.app.mapper.MemberMapper;
import org.springframework.beans.factory.annotation.Value;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@RequiredArgsConstructor
@Slf4j
@Service
public class MemberService
{
    private final MemberMapper memberMapper;

    @Value("${crypto.key}")
    private String cryptoKey;


    // 아이디 사용 가능 여부 확인
    public boolean isIdAvailable(String loginId)
    {
        return memberMapper.countById(loginId) == 0;
    }

    // 닉네임 사용 가능 여부 확인
    public boolean isNicknameAvailable(String nickname)
    {
        return memberMapper.countByNickname(nickname) == 0;
    }

    // 회원가입 처리
    // - encKey 를 vo 에 세팅 → SQL 에서 CRYPTPACK.ENCRYPT(pw, encKey) 로 암호화 저장
    // - MEMBER_MASTER → MEMBER_ACTIVE 순으로 INSERT (트랜잭션)
    @Transactional
    public void register(MemberVo memberVo)
    {
        memberVo.setEncKey(cryptoKey);
        memberMapper.insertMemberMaster(memberVo);
        memberMapper.insertMemberActive(memberVo);
    }

    // 로그인 인증
    // - encKey 와 loginId, pw 를 vo 에 담아 전달
    // - SQL 에서 CRYPTPACK.ENCRYPT(pw, encKey) 결과와 DB 저장값 비교
    // - 성공: MemberVo 반환 / 실패(아이디/비밀번호 불일치): null 반환
    // ※ 제재(정지) 여부는 isSuspended() 로 별도 확인 (로그인 엔드포인트 한정)
    public MemberVo login(String loginId, String pw)
    {
        MemberVo param = new MemberVo();
        param.setLoginId(loginId);
        param.setPw(pw);
        param.setEncKey(cryptoKey);
        return memberMapper.selectMemberLogin(param);
    }

    // 계정 정지 여부 확인
    // - MEMBER_SANCTION.SANCTION_UNTIL > SYSDATE 인 행이 있으면 true
    // - POST /login 에서 인증 성공 후 추가로 호출하여 정지 계정 차단
    // ※ 비밀번호 재확인(탈퇴 등)에는 사용하지 않음
    public boolean isSuspended(Long memberNo)
    {
        return memberMapper.checkSuspension(memberNo) > 0;
    }

    // 닉네임 사용 가능 여부 확인 - 자기 자신 제외 (정보수정 시 사용)
    public boolean isNicknameAvailableForUpdate(String nickname, Long memberNo)
    {
        return memberMapper.countByNicknameExcludeSelf(nickname, memberNo) == 0;
    }

    // 회원 정보 수정
    // - pw 가 입력된 경우 encKey 세팅 → SQL 에서 ENCRYPT 처리
    public void updateMember(MemberVo memberVo)
    {
        memberVo.setEncKey(cryptoKey);
        memberMapper.updateMember(memberVo);
    }

    // 즐겨찾기 목록 조회
    public List<BookmarkVo> getBookmarks(Long memberNo)
    {
        return memberMapper.selectBookmarksByMemberNo(memberNo);
    }

    // 리뷰 목록 조회
    public List<ReviewVo> getReviews(Long memberNo)
    {
        return memberMapper.selectReviewsByMemberNo(memberNo);
    }

    // 회원 탈퇴
    // 1) MEMBER_ACTIVE 데이터를 MEMBER_LEAVE 로 복사 (PW 포함, 암호화된 상태 그대로)
    // 2) MEMBER_ACTIVE 에서 삭제
    @Transactional
    public void withdraw(Long memberNo)
    {
        memberMapper.insertMemberLeave(memberNo);
        memberMapper.deleteMemberActive(memberNo);
    }
}
