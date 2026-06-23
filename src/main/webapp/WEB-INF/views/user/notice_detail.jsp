<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<c:set var="activePage" value="notice"/>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 공지사항 상세</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/user.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_user.jsp" %>

    <main class="mx-auto w-full max-w-3xl flex-1 p-6">

        <div class="mb-6 flex items-center gap-3">
            <a href="${pageContext.request.contextPath}/notice/list"
               class="flex items-center gap-1 text-sm text-slate-400 hover:text-slate-600 transition">
                <i data-lucide="arrow-left" class="h-4 w-4"></i> 목록으로
            </a>
            <h1 class="text-2xl font-bold text-slate-900">공지사항</h1>
        </div>

        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
            <!-- 제목 + 메타 -->
            <h2 class="text-xl font-bold text-slate-900">${notice.noticeTitle}</h2>
            <div class="mt-2 flex items-center gap-3 text-xs text-slate-400">
                <span>${notice.createDt}</span>
                <span class="flex items-center gap-1">
                    <i data-lucide="eye" class="h-3 w-3"></i> ${notice.viewCnt}
                </span>
            </div>
            <hr class="my-4 border-slate-100">
            <!-- 본문 — whitespace-pre-wrap 으로 줄바꿈 보존 -->
            <div class="whitespace-pre-wrap text-sm leading-relaxed text-slate-700">${notice.noticeContent}</div>
        </div>

        <div class="mt-6">
            <a href="${pageContext.request.contextPath}/notice/list"
               class="inline-flex items-center gap-1.5 rounded-xl bg-slate-100 px-4 py-2.5 font-semibold text-slate-600 transition hover:bg-slate-200">
                <i data-lucide="list" class="h-4 w-4"></i> 목록으로
            </a>
        </div>

    </main>
</div>

<script>const ctx = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/dist/js/common.js"></script>
</body>
</html>
