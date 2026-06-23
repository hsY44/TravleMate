<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<c:set var="activePage" value="qna"/>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 문의 상세</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/user.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_user.jsp" %>

    <main class="mx-auto w-full max-w-3xl flex-1 p-6">

        <div class="mb-6 flex items-center gap-3">
            <a href="${pageContext.request.contextPath}/qna/list"
               class="flex items-center gap-1 text-sm text-slate-400 hover:text-slate-600 transition">
                <i data-lucide="arrow-left" class="h-4 w-4"></i> 목록으로
            </a>
            <h1 class="text-2xl font-bold text-slate-900">문의 상세</h1>
        </div>

        <!-- 문의 내용 -->
        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
            <div class="mb-4 flex items-start justify-between gap-3">
                <div class="flex-1 min-w-0">
                    <div class="mb-1 flex items-center gap-2">
                        <span class="rounded-full bg-sky-100 px-2 py-0.5 text-xs font-semibold text-sky-600">${qna.qnaTypeNm}</span>
                        <span class="shrink-0 rounded-full px-2 py-0.5 text-xs font-semibold
                            ${qna.statusCd eq 'ST002' ? 'bg-emerald-100 text-emerald-600' : 'bg-amber-100 text-amber-600'}">
                            ${qna.statusCd eq 'ST002' ? '답변 완료' : '답변 대기'}
                        </span>
                    </div>
                    <h2 class="text-lg font-semibold text-slate-900">${qna.qnaTitle}</h2>
                    <p class="mt-1 text-xs text-slate-400">${qna.createDt}</p>
                </div>
            </div>
            <hr class="border-slate-100">
            <div class="mt-4 whitespace-pre-wrap text-sm leading-relaxed text-slate-700">${qna.qnaContent}</div>
        </div>

        <!-- 관리자 답변 (답변 완료 시만 표시) -->
        <c:if test="${qna.statusCd eq 'ST002' and not empty qna.ansContent}">
            <div class="mt-4 rounded-2xl border border-emerald-100 bg-emerald-50 p-6">
                <p class="mb-3 text-sm font-semibold text-emerald-600">관리자 답변</p>
                <div class="whitespace-pre-wrap text-sm leading-relaxed text-slate-700">${qna.ansContent}</div>
            </div>
        </c:if>

        <div class="mt-6">
            <a href="${pageContext.request.contextPath}/qna/list"
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
