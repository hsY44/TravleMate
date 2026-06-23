<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<aside class="hidden h-screen w-60 shrink-0 flex-col border-r border-slate-200 bg-white p-5 md:flex">
    <!-- 로고 -->
    <div class="mb-8 flex items-center gap-2">
        <div class="flex h-9 w-9 items-center justify-center rounded-lg bg-sky-500">
            <i data-lucide="plane" class="h-5 w-5 text-white"></i>
        </div>
        <span class="text-lg font-bold text-sky-500">트래블메이트</span>
    </div>

    <!-- 네비게이션: activePage 값으로 현재 메뉴 강조 -->
    <nav class="flex flex-1 flex-col gap-1">
        <a href="${ctx}/plans"
           class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold transition
               ${activePage eq 'plans' ? 'bg-sky-50 text-sky-600' : 'text-slate-500 hover:bg-slate-50'}">
            <i data-lucide="map" class="h-5 w-5"></i> 여행계획
        </a>
        <a href="${ctx}/contents"
           class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold transition
               ${activePage eq 'contents' ? 'bg-sky-50 text-sky-600' : 'text-slate-500 hover:bg-slate-50'}">
            <i data-lucide="compass" class="h-5 w-5"></i> 여행지 탐색
        </a>
        <a href="${ctx}/notice/list"
           class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold transition
               ${activePage eq 'notice' ? 'bg-sky-50 text-sky-600' : 'text-slate-500 hover:bg-slate-50'}">
            <i data-lucide="bell" class="h-5 w-5"></i> 공지사항
        </a>
        <a href="${ctx}/mypage"
           class="flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold transition
               ${activePage eq 'mypage' ? 'bg-sky-50 text-sky-600' : 'text-slate-500 hover:bg-slate-50'}">
            <i data-lucide="user" class="h-5 w-5"></i> 마이페이지
        </a>
    </nav>

    <!-- 로그인 사용자 정보 + 로그아웃 -->
    <c:if test="${not empty sessionScope.nickname}">
        <div class="mt-auto border-t border-slate-200 pt-4">
            <div class="mb-2 px-1 text-sm font-semibold text-slate-900">${sessionScope.nickname}님</div>
            <a href="${ctx}/logout" class="flex items-center gap-2 px-1 text-sm text-slate-400 hover:text-slate-600">
                <i data-lucide="log-out" class="h-4 w-4"></i> 로그아웃
            </a>
        </div>
    </c:if>

</aside>