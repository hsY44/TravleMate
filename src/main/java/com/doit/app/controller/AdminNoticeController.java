/*===============================================
AdminNoticeController.java
- 관리자 공지사항 관리 컨트롤러
- 공지사항 목록 조회, 등록/수정/삭제 (AJAX)
- /admin/notices - 사이드바 'notices' 메뉴에 연결
===============================================*/
package com.doit.app.controller;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.AdminVo;
import com.doit.app.domain.NoticeVo;
import com.doit.app.service.AdminNoticeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@Slf4j
@Controller
public class AdminNoticeController
{
    private final AdminNoticeService adminNoticeService;

private boolean isAdminLoggedIn(HttpSession session)
{
    return session.getAttribute("loginAdmin") != null;
}

private Long adminNo(HttpSession session)
{
    AdminVo admin = (AdminVo) session.getAttribute("loginAdmin");
    return admin.getAdminNo();
}


//  공지사항 목록 (GET /admin/notices - 사이드바 연결)

@GetMapping("/admin/notices")
public String noticeList(@RequestParam(name="page", defaultValue = "1") int page,
                          HttpSession session, Model model)
{
    if (!isAdminLoggedIn(session)) { return "redirect:/login"; }

    PaginateUtil pageInfo     = adminNoticeService.createPageInfo(page);
    List<NoticeVo> notices    = adminNoticeService.getNotices(page, pageInfo);

    model.addAttribute("notices",  notices);
    model.addAttribute("pageInfo", pageInfo);
    return "admin/notice";
}


//  공지사항 CRUD (AJAX)

// GET /admin/notice/{noticeNo} - 수정 모달 pre-fill용 단건 조회
@GetMapping("/admin/notice/{noticeNo}")
@ResponseBody
public ResponseEntity<NoticeVo> getNotice(@PathVariable(name = "noticeNo") Long noticeNo,
                                           HttpSession session)
{
    if (!isAdminLoggedIn(session)) { return ResponseEntity.status(401).build(); }
    NoticeVo notice = adminNoticeService.getNotice(noticeNo);
    if (notice == null) { return ResponseEntity.notFound().build(); }
    return ResponseEntity.ok(notice);
}

// POST /admin/notice - 등록
@PostMapping("/admin/notice")
@ResponseBody
public ResponseEntity<Map<String, Object>> addNotice(@RequestBody Map<String, String> body,
                                                      HttpSession session)
{
    if (!isAdminLoggedIn(session)) { return ResponseEntity.status(401).body(Map.of("result", "unauthorized")); }
    int rows = adminNoticeService.addNotice(
        adminNo(session),
        body.get("noticeTitle"),
        body.get("noticeContent")
    );
    return ResponseEntity.ok(Map.of("result", rows > 0 ? "ok" : "fail"));
}

// PUT /admin/notice/{noticeNo} - 수정
@PutMapping("/admin/notice/{noticeNo}")
@ResponseBody
public ResponseEntity<Map<String, Object>> editNotice(@PathVariable(name = "noticeNo") Long noticeNo,
                                                       @RequestBody  Map<String, String> body,
                                                       HttpSession session)
{
    if (!isAdminLoggedIn(session)) { return ResponseEntity.status(401).body(Map.of("result", "unauthorized")); }
    int rows = adminNoticeService.editNotice(
        noticeNo,
        body.get("noticeTitle"),
        body.get("noticeContent")
    );
    return ResponseEntity.ok(Map.of("result", rows > 0 ? "ok" : "fail"));
}

// DELETE /admin/notice/{noticeNo} - 삭제
@DeleteMapping("/admin/notice/{noticeNo}")
@ResponseBody
public ResponseEntity<Map<String, Object>> deleteNotice(@PathVariable(name = "noticeNo") Long noticeNo,
                                                         HttpSession session)
{
    if (!isAdminLoggedIn(session)) { return ResponseEntity.status(401).body(Map.of("result", "unauthorized")); }
    int rows = adminNoticeService.removeNotice(noticeNo);
    return ResponseEntity.ok(Map.of("result", rows > 0 ? "ok" : "fail"));
}
}
