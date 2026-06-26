/*===============================================
    KakaoController.java
    - Kakao Local API 장소 검색 엔드포인트
    - GET /kakao/places?kwd=검색어
===============================================*/
package com.doit.app.controller;

import com.doit.app.domain.KakaoPlaceVo;
import com.doit.app.service.KakaoLocalService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
@RequiredArgsConstructor
@Slf4j
public class KakaoController
{
    private final KakaoLocalService kakaoLocalService;

    /**
     * GET /kakao/places?kwd=검색어&cgc=카테고리코드
     * - Kakao Local API 장소 검색 (로그인 필요)
     * - cgc: AD5(숙박) FD6(음식점) CE7(카페) MT1(쇼핑) — 생략 시 전체 검색
     * - 응답: KakaoPlaceVo[] (placeName, addressName, x, y, categoryName)
     * - 프론트: 장소 선택 시 x→mapX, y→mapY 로 일정 저장
     */
    @GetMapping("/kakao/places")
    @ResponseBody
    public ResponseEntity<?> searchPlaces(@RequestParam(name = "kwd") String kwd,
                                          @RequestParam(name = "cgc", required = false) String cgc,
                                          HttpSession session)
    {
        if (session.getAttribute("loginMember") == null) {
            return ResponseEntity.status(401).body("로그인이 필요합니다.");
        }
        try {
            List<KakaoPlaceVo> places = kakaoLocalService.search(kwd, cgc);
            return ResponseEntity.ok(places);
        } catch (Exception e) {
            log.error("searchPlaces : ", e);
            return ResponseEntity.internalServerError().build();
        }
    }
}
