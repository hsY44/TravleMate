/*===============================================
    AdminThemeService.java
    - 관리자 여행 테마 관리 비즈니스 로직
===============================================*/
package com.doit.app.service;

import com.doit.app.domain.ThemeVo;
import com.doit.app.mapper.AdminThemeMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@RequiredArgsConstructor
@Slf4j
@Service
public class AdminThemeService
{
    private final AdminThemeMapper adminThemeMapper;

    public List<ThemeVo> getAllThemes()
    {
        return adminThemeMapper.selectAllThemes();
    }

    @Transactional
    public void saveTheme(String cd, String nm)
    {
        if (adminThemeMapper.countThemeCd(cd) > 0) {
            adminThemeMapper.updateTheme(cd, nm);
        } else {
            adminThemeMapper.insertTheme(cd, nm);
        }
    }

    /**
     * 테마 삭제
     * 사용 중인 여행계획이 있으면 삭제 불가 → "INUSE" 반환
     * 성공 시 "OK" 반환
     */
    @Transactional
    public String deleteTheme(String cd)
    {
        if (adminThemeMapper.countPlansByThemeCd(cd) > 0) {
            return "INUSE";
        }
        adminThemeMapper.deleteTheme(cd);
        return "OK";
    }
}
