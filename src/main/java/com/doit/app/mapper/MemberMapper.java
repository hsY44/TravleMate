/*===============================================
    MemberMapper.java
    - 회원 관련 MyBatis Mapper 인터페이스
    - memberMapper.xml 과 연결
===============================================*/
package com.doit.app.mapper;

import com.doit.app.domain.BookmarkVo;
import com.doit.app.domain.MemberVo;
import com.doit.app.domain.ReviewVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface MemberMapper
{
    // 회원 마스터 INSERT (시퀀스로 MEMBER_NO 생성 후 vo.memberNo 에 반영)
    int insertMemberMaster(MemberVo vo);

    // 활동 회원 INSERT
    int insertMemberActive(MemberVo vo);

    // 로그인 - 아이디/암호화 비밀번호 일치 회원 조회 (encKey 로 ENCRYPT 비교)
    MemberVo selectMemberLogin(MemberVo vo);

    // 현재 유효한 제재 이력 존재 여부 (1 이상: 정지 중, 0: 정상)
    // - MEMBER_SANCTION.SANCTION_UNTIL > SYSDATE 인 행 수 반환
    int checkSuspension(Long memberNo);

    // 아이디 중복 확인 (0: 사용 가능, 1 이상: 이미 존재)
    int countById(String loginId);

    // 닉네임 중복 확인
    int countByNickname(String nickname);

    // 닉네임 중복 확인 - 자기 자신(memberNo) 제외 (정보수정 시 사용)
    int countByNicknameExcludeSelf(@Param("nickname") String nickname,
                                   @Param("memberNo") Long memberNo);

    // 회원 정보 수정 (비밀번호는 입력 시에만 변경)
    int updateMember(MemberVo vo);

    // 즐겨찾기 목록 조회 - MEMBER_BOOKMARK JOIN CONTENT JOIN CONTENTCATEGORY
    List<BookmarkVo> selectBookmarksByMemberNo(Long memberNo);

    // 리뷰 목록 조회 - CONTENT_REVIEW JOIN CONTENT
    List<ReviewVo> selectReviewsByMemberNo(Long memberNo);

    // 탈퇴 처리 1) : MEMBER_ACTIVE 데이터를 MEMBER_LEAVE 로 복사 (PW 포함 SELECT-INSERT)
    int insertMemberLeave(Long memberNo);

    // 탈퇴 처리 2) : MEMBER_ACTIVE 에서 삭제
    int deleteMemberActive(Long memberNo);
}
