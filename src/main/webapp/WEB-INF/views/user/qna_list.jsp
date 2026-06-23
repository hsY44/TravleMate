<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<c:set var="activePage" value="qna"/>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 문의 내역</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/user.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_user.jsp" %>

    <main class="mx-auto w-full max-w-3xl flex-1 p-6">

        <div class="mb-6 flex items-center justify-between">
            <h1 class="text-2xl font-bold text-slate-900">문의 내역</h1>
            <a href="${pageContext.request.contextPath}/qna/form"
               class="flex items-center gap-1.5 rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">
                <i data-lucide="plus" class="h-4 w-4"></i> 문의하기
            </a>
        </div>

        <c:choose>
            <c:when test="${not empty qnaList}">
                <div class="flex flex-col gap-3">
                    <c:forEach var="qna" items="${qnaList}">
                        <a href="${pageContext.request.contextPath}/qna/detail/${qna.qnaReqNo}"
                           class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm hover:shadow-md transition">
                            <div class="flex items-start justify-between gap-2">
                                <div class="flex-1 min-w-0">
                                    <div class="flex items-center gap-2">
                                        <span class="rounded-full bg-sky-100 px-2 py-0.5 text-xs font-semibold text-sky-600">${qna.qnaTypeNm}</span>
                                        <span class="truncate text-sm font-semibold text-slate-900">${qna.qnaTitle}</span>
                                    </div>
                                    <p class="mt-1 text-xs text-slate-400">${qna.createDt}</p>
                                </div>
                                <!-- 답변 상태 뱃지 — ST001:답변 대기, ST002:답변 완료 -->
                                <span class="shrink-0 rounded-full px-2 py-0.5 text-xs font-semibold
                                    ${qna.statusCd eq 'ST002' ? 'bg-emerald-100 text-emerald-600' : 'bg-amber-100 text-amber-600'}">
                                    ${qna.statusCd eq 'ST002' ? '답변 완료' : '답변 대기'}
                                </span>
                            </div>
                            <c:if test="${qna.statusCd eq 'ST002' and not empty qna.ansContent}">
                                <div class="mt-3 rounded-xl border border-slate-100 bg-slate-50 p-3 text-sm text-slate-600">
                                    <p class="mb-1 text-xs font-semibold text-slate-400">관리자 답변</p>
                                    ${qna.ansContent}
                                </div>
                            </c:if>
                        </a>
                    </c:forEach>
                </div>

                <!-- 페이징 버튼 -->
                <c:if test="${pageInfo.totalPages > 1}">
                    <nav class="mt-6 flex items-center justify-center gap-1">
                        <!-- 이전 블록 -->
                        <c:if test="${pageInfo.hasPrev()}">
                            <a href="?page=${pageInfo.blockStart - 1}"
                               class="flex h-9 w-9 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-500 hover:bg-slate-50 transition">
                                <i data-lucide="chevron-left" class="h-4 w-4"></i>
                            </a>
                        </c:if>

                        <!-- 페이지 번호 버튼 -->
                        <c:forEach begin="${pageInfo.blockStart}" end="${pageInfo.blockEnd}" var="p">
                            <a href="?page=${p}"
                               class="flex h-9 w-9 items-center justify-center rounded-xl border text-sm font-semibold transition
                                   ${p eq pageInfo.page
                                       ? 'border-sky-500 bg-sky-500 text-white'
                                       : 'border-slate-200 bg-white text-slate-600 hover:bg-slate-50'}">
                                ${p}
                            </a>
                        </c:forEach>

                        <!-- 다음 블록 -->
                        <c:if test="${pageInfo.hasNext()}">
                            <a href="?page=${pageInfo.blockEnd + 1}"
                               class="flex h-9 w-9 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-500 hover:bg-slate-50 transition">
                                <i data-lucide="chevron-right" class="h-4 w-4"></i>
                            </a>
                        </c:if>
                    </nav>
                </c:if>

            </c:when>
            <c:otherwise>
                <div class="flex flex-col items-center justify-center rounded-2xl border border-dashed border-slate-200 bg-white py-20 text-center">
                    <i data-lucide="message-square" class="mb-4 h-10 w-10 text-slate-300"></i>
                    <p class="mb-3 text-sm text-slate-400">문의 내역이 없습니다</p>
                    <a href="${pageContext.request.contextPath}/qna/form"
                       class="rounded-xl bg-sky-500 px-4 py-2 text-sm font-semibold text-white transition hover:bg-sky-600">
                        문의하기
                    </a>
                </div>
            </c:otherwise>
        </c:choose>

    </main>
</div>

<script>const ctx = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/dist/js/common.js"></script>
</body>
</html>
