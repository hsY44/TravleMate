package com.doit.app.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.GetMapping;


@RequiredArgsConstructor
@Slf4j
@Controller
@RequestMapping("/")
public class MainController {

	@GetMapping("")
	public String main() {
		return "redirect:/contents/list";
	}

	// 콘텐츠 목록으로 이동
	@GetMapping("/contents")
	public String contentsMain() {
		return "redirect:/contents/list";
	}
}
