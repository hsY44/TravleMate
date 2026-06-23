<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<c:set var="activePage" value="notice"/>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 공지사항</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/user.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_user.jsp" %>

    <main class="mx-auto w-full max-w-3xl flex-1 p-6">
        <h1 class="mb-6 text-2xl font-bold text-slate-900">공지사항</h1>

        <c:choose>
            <c:when test="${not empty notices}">
                <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
                    <c:forEach var="notice" items="${notices}" varStatus="vs">
                        <a href="${pageContext.request.contextPath}/notice/${notice.noticeNo}"
                           class="flex items-center justify-between gap-4 px-5 py-4 transition hover:bg-slate-50
                               ${vs.last ? '' : 'border-b border-slate-100'}">
                            <div class="min-w-0 flex-1">
                                <p class="truncate font-semibold text-slate-900">${notice.noticeTitle}</p>
                                <p class="mt-0.5 text-xs text-slate-400">${notice.createDt}</p>
                            </div>
                            <div class="flex shrink-0 items-center gap-3 text-xs text-slate-400">
                                <span class="flex items-center gap-1">
                                    <i data-lucide="eye" class="h-3 w-3"></i> ${notice.viewCnt}
                                </span>
                                <i data-lucide="chevron-right" class="h-4 w-4"></i>
                            </div>
                        </a>
                    </c:forEach>
                </div>

                <!-- 페이징 버튼 -->
                <c:if test="${pageInfo.totalPages > 1}">
                    <nav class="mt-6 flex items-center justify-center gap-1">
                        <c:if test="${pageInfo.hasPrev()}">
                            <a href="?page=${pageInfo.blockStart - 1}"
                               class="flex h-9 w-9 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-500 hover:bg-slate-50 transition">
                                <i data-lucide="chevron-left" class="h-4 w-4"></i>
                            </a>
                        </c:if>
                        <c:forEach begin="${pageInfo.blockStart}" end="${pageInfo.blockEnd}" var="p">
                            <a href="?page=${p}"
                               class="flex h-9 w-9 items-center justify-center rounded-xl border text-sm font-semibold transition
                                   ${p eq pageInfo.page
                                       ? 'border-sky-500 bg-sky-500 text-white'
                                       : 'border-slate-200 bg-white text-slate-600 hover:bg-slate-50'}">
                                ${p}
                            </a>
                        </c:forEach>
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
                    <i data-lucide="bell" class="mb-4 h-10 w-10 text-slate-300"></i>
                    <p class="text-sm text-slate-400">등록된 공지사항이 없습니다</p>
                </div>
            </c:otherwise>
        </c:choose>

    </main>
</div>

<script>const ctx = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/dist/js/common.js"></script>
</body>
</html>
