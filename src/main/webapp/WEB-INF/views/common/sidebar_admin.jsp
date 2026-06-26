<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<aside class="flex w-56 shrink-0 flex-col bg-slate-800 p-4 text-slate-200">

    <!-- 로고 -->
    <div class="mb-8 flex items-center gap-2 px-2 pt-2">
        <div class="flex h-9 w-9 items-center justify-center rounded-lg bg-sky-500">
            <i data-lucide="plane" class="h-5 w-5 text-white"></i>
        </div>
        <div class="leading-tight">
            <p class="text-sm font-bold text-white">트래블메이트</p>
            <p class="text-xs text-slate-400">관리자</p>
        </div>
    </div>

    <!-- 네비게이션: activePage 값으로 현재 메뉴 강조 -->
    <nav class="flex flex-1 flex-col gap-1">
        <a href="${ctx}/admin/members"
           class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-semibold transition
               ${activePage eq 'members' ? 'bg-sky-500 text-white' : 'text-slate-300 hover:bg-slate-700'}">
            <i data-lucide="users" class="h-5 w-5"></i> 회원관리
        </a>
        <a href="${ctx}/admin/contents"
           class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-semibold transition
               ${activePage eq 'contents' ? 'bg-sky-500 text-white' : 'text-slate-300 hover:bg-slate-700'}">
            <i data-lucide="map-pin" class="h-5 w-5"></i> 컨텐츠
        </a>
        <a href="${ctx}/admin/reviews"
           class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-semibold transition
               ${activePage eq 'review' ? 'bg-sky-500 text-white' : 'text-slate-300 hover:bg-slate-700'}">
            <i data-lucide="pencil" class="h-5 w-5"></i> 리뷰내역
        </a>
        <a href="${ctx}/admin/notices"
           class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-semibold transition
               ${activePage eq 'notices' ? 'bg-sky-500 text-white' : 'text-slate-300 hover:bg-slate-700'}">
            <i data-lucide="megaphone" class="h-5 w-5"></i> 공지사항
        </a>
        <a href="${ctx}/admin/faqs"
           class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-semibold transition
               ${activePage eq 'faqs' ? 'bg-sky-500 text-white' : 'text-slate-300 hover:bg-slate-700'}">
            <i data-lucide="help-circle" class="h-5 w-5"></i> FAQ
        </a>
        <a href="${ctx}/admin/qnas"
           class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-semibold transition
               ${activePage eq 'qnas' ? 'bg-sky-500 text-white' : 'text-slate-300 hover:bg-slate-700'}">
            <i data-lucide="message-square" class="h-5 w-5"></i> 문의관리
        </a>
        <a href="${ctx}/admin/leaveMembers"
           class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-semibold transition
               ${activePage eq 'leaveMembers' ? 'bg-sky-500 text-white' : 'text-slate-300 hover:bg-slate-700'}">
            <i data-lucide="user-x" class="h-5 w-5"></i> 탈퇴회원
        </a>
        <a href="${ctx}/admin/category"
           class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-semibold transition
               ${(activePage eq 'category' or activePage eq 'theme') ? 'bg-sky-500 text-white' : 'text-slate-300 hover:bg-slate-700'}">
            <i data-lucide="folder" class="h-5 w-5"></i> 카테고리 관리
        </a>
    </nav>

    <!-- 로그아웃 -->
    <a href="${ctx}/logout" class="flex items-center gap-2 px-3 py-2 text-sm text-slate-400 hover:text-slate-200">
        <i data-lucide="log-out" class="h-4 w-4"></i> 로그아웃
    </a>

</aside>
