/*===============================================
    AdminThemeController.java
    - 관리자 여행 테마 관리 컨트롤러
    - GET  /admin/theme        : 목록 페이지
    - POST /admin/theme        : 등록 (AJAX)
    - PUT  /admin/theme/{cd}   : 수정 (AJAX)
    - DELETE /admin/theme/{cd} : 삭제 (AJAX)
===============================================*/
package com.doit.app.controller;

import com.doit.app.service.AdminThemeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RequiredArgsConstructor
@Slf4j
@Controller
public class AdminThemeController
{
    private final AdminThemeService adminThemeService;


    private boolean isAdminLoggedIn(HttpSession session)
    {
        return session.getAttribute("loginAdmin") != null;
    }

    // GET /admin/theme
    @GetMapping("/admin/theme")
    public String themePage(HttpSession session, Model model)
    {
        if (!isAdminLoggedIn(session)) { return "redirect:/login"; }
        model.addAttribute("themes", adminThemeService.getAllThemes());
        return "admin/theme";
    }

    // POST /admin/theme - 등록 (AJAX)
    @PostMapping("/admin/theme")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> addTheme(@RequestParam(name = "cd") String cd,
                                                         @RequestParam(name = "nm") String nm,
                                                         HttpSession session)
    {
        if (!isAdminLoggedIn(session)) {
            return ResponseEntity.status(401).body(Map.of("result", "unauthorized"));
        }
        adminThemeService.saveTheme(cd.trim().toUpperCase(), nm.trim());
        return ResponseEntity.ok(Map.of("result", "ok"));
    }

    // PUT /admin/theme/{cd} - 수정 (AJAX)
    @PutMapping("/admin/theme/{cd}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> editTheme(@PathVariable(name = "cd") String cd,
                                                          @RequestParam(name = "nm") String nm,
                                                          HttpSession session)
    {
        if (!isAdminLoggedIn(session)) {
            return ResponseEntity.status(401).body(Map.of("result", "unauthorized"));
        }
        adminThemeService.saveTheme(cd.trim(), nm.trim());
        return ResponseEntity.ok(Map.of("result", "ok"));
    }

    // DELETE /admin/theme/{cd} - 삭제 (AJAX)
    @DeleteMapping("/admin/theme/{cd}")
    @ResponseBody
    public ResponseEntity<Map<String, Object>> deleteTheme(@PathVariable(name = "cd") String cd,
                                                            HttpSession session)
    {
        if (!isAdminLoggedIn(session)) {
            return ResponseEntity.status(401).body(Map.of("result", "unauthorized"));
        }
        String result = adminThemeService.deleteTheme(cd.trim());
        // INUSE: 여행계획에서 사용 중 → 409 Conflict
        if ("INUSE".equals(result)) {
            return ResponseEntity.status(409).body(Map.of("result", "inuse"));
        }
        return ResponseEntity.ok(Map.of("result", "ok"));
    }
}
