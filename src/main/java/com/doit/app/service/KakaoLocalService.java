/*===============================================
    KakaoLocalService.java
    - Kakao Local REST API 장소 검색 서비스
    - 엔드포인트: GET https://dapi.kakao.com/v2/local/search/keyword.json
    - 인증: Authorization: KakaoAK {REST API 키}
    - 저장 항목: placeName(이름), x(경도), y(위도) — 이미지 없음
===============================================*/
package com.doit.app.service;

import com.doit.app.domain.KakaoPlaceVo;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class KakaoLocalService
{
    @Value("${kakao.local.key:}")
    private String localKey;

    private final ObjectMapper objectMapper;

    private static final String SEARCH_URL = "https://dapi.kakao.com/v2/local/search/keyword.json";

    /**
     * keyword로 Kakao Local API 장소 검색
     * @param categoryGroupCode 카테고리 필터 (AD5:숙박 FD6:음식점 CE7:카페 MT1:쇼핑 / null이면 전체)
     * @return 최대 15건 — API 오류 시 빈 리스트 반환
     */
    public List<KakaoPlaceVo> search(String keyword, String categoryGroupCode) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.set("Authorization", "KakaoAK " + localKey);

            String url = SEARCH_URL
                    + "?query=" + URLEncoder.encode(keyword, StandardCharsets.UTF_8)
                    + "&size=15";

            if (categoryGroupCode != null && !categoryGroupCode.isBlank()) {
                url += "&category_group_code=" + categoryGroupCode;
            }

            RestTemplate rt = new RestTemplate();
            ResponseEntity<String> resp = rt.exchange(url, HttpMethod.GET, new HttpEntity<>(headers), String.class);

            JsonNode docs = objectMapper.readTree(resp.getBody()).get("documents");
            List<KakaoPlaceVo> result = new ArrayList<>();

            if (docs != null && docs.isArray()) {
                for (JsonNode doc : docs) {
                    KakaoPlaceVo vo = new KakaoPlaceVo();
                    vo.setPlaceName(doc.path("place_name").asText(""));
                    vo.setAddressName(doc.path("address_name").asText(""));
                    vo.setX(doc.path("x").asText(""));
                    vo.setY(doc.path("y").asText(""));
                    vo.setCategoryName(doc.path("category_name").asText(""));
                    result.add(vo);
                }
            }
            return result;

        } catch (Exception e) {
            log.info("Kakao Local API 호출 실패 : ", e);
            return List.of();
        }
    }
}
