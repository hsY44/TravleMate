/*===============================================
    NoticeController.java
    - 사용자 공지사항 컨트롤러
    - 공지사항 목록 / 상세
===============================================*/
package com.doit.app.controller;

import com.doit.app.common.PaginateUtil;
import com.doit.app.domain.NoticeVo;
import com.doit.app.service.NoticeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@RequiredArgsConstructor
@Slf4j
@Controller
@RequestMapping("/notice")
public class NoticeController
{
    private final NoticeService noticeService;


    // 공지사항 목록 (GET /notice/list?page=1)
    @GetMapping("/list")
    public String noticeList(@RequestParam(name = "page", defaultValue = "1") int page,
                             Model model)
    {
        PaginateUtil pageInfo      = noticeService.createPageInfo(page);
        List<NoticeVo> notices     = noticeService.getNotices(page, pageInfo);

        model.addAttribute("notices",  notices);
        model.addAttribute("pageInfo", pageInfo);
        return "user/notice_list";
    }

    // 공지사항 상세 (GET /notice/{noticeNo})
    // 조회수 증가 후 단건 조회
    @GetMapping("/{noticeNo}")
    public String noticeDetail(@PathVariable(name = "noticeNo") Long noticeNo,
                               Model model)
    {
        NoticeVo notice = noticeService.getNotice(noticeNo);
        if (notice == null) { return "redirect:/notice/list"; }

        model.addAttribute("notice", notice);
        return "user/notice_detail";
    }
}
