/*===============================================
    AdminThemeMapper.java
    - 관리자 여행 테마 관리 MyBatis Mapper
===============================================*/
package com.doit.app.mapper;

import com.doit.app.domain.ThemeVo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface AdminThemeMapper
{
    List<ThemeVo> selectAllThemes();

    int countThemeCd(@Param("cd") String cd);

    void insertTheme(@Param("cd") String cd, @Param("nm") String nm);

    void updateTheme(@Param("cd") String cd, @Param("nm") String nm);

    // 해당 테마를 사용 중인 여행계획 수 (삭제 가능 여부 판단)
    int countPlansByThemeCd(@Param("cd") String cd);

    void deleteTheme(@Param("cd") String cd);
}
