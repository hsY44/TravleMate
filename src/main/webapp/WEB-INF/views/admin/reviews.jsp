<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx"        value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="reviews"/>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 리뷰 내역</title>
    <link rel="stylesheet" href="${ctx}/dist/css/admin.css">
    <script type="text/javascript">

        // 조건없음(none)일 경우 입력창 disabled
        document.addEventListener("DOMContentLoaded", function () {
            const selectEl = document.getElementById("schType");

            function handleSelectChange(value) {
                const kwdInput = document.getElementById("kwdInput");
                if (value === "none") {
                    kwdInput.disabled = true;
                    kwdInput.value = "";
                }
                else
                    kwdInput.disabled = false;
            }
            selectEl.addEventListener("change", function (event) {
                handleSelectChange(event.target.value);
            });
            handleSelectChange(selectEl.value);
        });

        function searchReview() {
            const f = document.searchForm;
            if (f.schType.value == 'none') {
                document.getElementById("kwdInput").value = "";
            }
            f.submit();
        }


    </script>
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_admin.jsp" %>

    <main class="flex-1 p-6">
        <div class="mx-auto max-w-6xl">
            <h1 class="mb-6 text-2xl font-bold text-slate-900">리뷰 내역</h1>

            <!-- 필터 -->
            <form name="searchForm" action="${ctx}/admin/reviews" method="get" class="mb-4 flex flex-wrap gap-2">
                <select name="schType"
                        id="schType"
                        class="rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                    <option value="none">조건없음</option>
                    <option value="contentId" ${param.schType eq 'contentId' ? 'selected' : ''}>컨텐츠ID</option>
                    <option value="reviewNo" ${param.schType eq 'reviewNo' ? 'selected' : ''}>리뷰번호</option>
                    <option value="comment" ${param.schType eq 'comment' ? 'selected' : ''}>내용</option>
                    <option value="nickName" ${param.schType eq 'nickName' ? 'selected' : ''}>닉네임</option>
                </select>

                <div class="flex gap-2">
                    <div class="relative">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                             stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                             class="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-400">
                             <circle cx="11" cy="11" r="8"></circle>
                             <path d="m21 21-4.3-4.3"></path></svg>
                        <input type="text" name="kwd" id="kwdInput" value="${param.kwd}"
                               placeholder="키워드로 검색"
                               class="w-full rounded-xl border border-slate-200 py-2.5 pl-10 pr-3 focus:outline-none focus:ring-2 focus:ring-sky-400">
                    </div>
                    <button type="button" class="rounded-xl px-4 py-2.5 font-semibold transition bg-sky-500 text-white hover:bg-sky-600"
						onclick="searchReview()">검색</button>
                </div>
            </form>

            <!-- 신고 목록 테이블 -->
            <div class="overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>리뷰번호</th>
                            <th>컨텐츠ID</th>
                            <th>작성자</th>
                            <th>내용</th>
                            <th>별점</th>
                            <th>작성일</th>
                            <th>상태</th>
                            <!-- <th>관리</th> -->
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${reviewList}">
                            <tr>
                                <td class="text-slate-400">${r.contentReviewNo}</td>
                                <td class="text-slate-400">${r.contentId}</td>
                                <td class="whitespace-nowrap">${r.nickname}</td>
                                <td class="max-w-xs truncate">${r.reviewComment}</td>
                                <td class="max-w-xs truncate">${r.rating}</td>
                                <td class="whitespace-nowrap">${r.createDt}</td>
                                <td class="whitespace-nowrap">
                                    <!-- 처리 상태에 따라 뱃지 클래스 분기 -->
                                    <span class="rounded-full px-2 py-0.5 text-xs font-semibold
                                        ${r.blindYn eq 'Y' ? 'badge-pending' : 'badge-resolved'}">
                                        <c:choose>
                                            <c:when test="${r.blindYn eq 'Y'}">숨김</c:when>
                                            <c:otherwise>정상</c:otherwise>
                                        </c:choose>
                                    </span>
                                </td>
                            </tr>
                        </c:forEach>
                        <!-- 신고 내역 없음 -->
                        <c:if test="${empty reviewList}">
                            <tr>
                                <td colspan="7" class="py-10 text-center text-slate-400">신고 내역이 없습니다.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>


            <!-- 페이징 -->
			<c:if test="${pageInfo.totalPages > 1}">
               	<nav class="mt-6 flex items-center justify-center gap-1">
                    <!-- 이전 블록 -->
					<c:if test="${pageInfo.hasPrev()}">
                        <a href="${listUrl}${fn:contains(listUrl, '?') ? '&' : '?'}page=${pageInfo.blockStart - 1}"
                           class="flex h-9 w-9 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-500 hover:bg-slate-50 transition">
                            <i data-lucide="chevron-left" class="h-4 w-4"></i>
                        </a>
                    </c:if>

                    <!-- 페이지 번호 -->
                    <c:forEach begin="${pageInfo.blockStart}" end="${pageInfo.blockEnd}" var="p">
                        <a href="${listUrl}${fn:contains(listUrl, '?') ? '&' : '?'}page=${p}"
                           class="flex h-9 w-9 items-center justify-center rounded-xl border text-sm font-semibold transition
	                                  ${p eq pageInfo.page
	                                      ? 'border-sky-500 bg-sky-500 text-white'
	                                      : 'border-slate-200 bg-white text-slate-600 hover:bg-slate-50'}">
                                ${p}
                        </a>
                    </c:forEach>

                    <!-- 다음 블록 -->
                    <c:if test="${pageInfo.hasNext()}">
                        <a href="${listUrl}${fn:contains(listUrl, '?') ? '&' : '?'}page=${pageInfo.blockEnd + 1}"
                           class="flex h-9 w-9 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-500 hover:bg-slate-50 transition">
                            <i data-lucide="chevron-right" class="h-4 w-4"></i>
                        </a>
                    </c:if>
                </nav>
            </c:if>
        </div>
    </main>
</div>

<script>const ctx = '${pageContext.request.contextPath}';</script>
<script src="${ctx}/dist/js/common.js"></script>
</body>
</html>
