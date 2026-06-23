<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx"        value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="contents"/>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 컨텐츠</title>
    <link rel="stylesheet" href="${ctx}/dist/css/admin.css">
    <link rel="stylesheet" href="${ctx}/dist/css/user.css">
    <script type="text/javascript">

        function searchContent() {

            const f = document.searchForm;

            const kwd = f.kwd;

            if (! kwd.value.trim()) {
                showToast("검색어를 입력해 주세요.", 1500, "info");
                return;
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

            <!-- 헤더 -->
            <div class="mb-6 flex items-center justify-between">
                <h1 class="text-2xl font-bold text-slate-900">컨텐츠</h1>
                <div class="flex gap-2">
                    <a href="${pageContext.request.contextPath}/admin/category"
                       class="rounded-xl border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-50">
                        컨텐츠 카테고리
                    </a>
                </div>
            </div>

            <!-- 검색 + 카테고리 탭 (sticky) -->
			<div class="sticky top-0 z-10 -mx-6 mb-4 bg-slate-50 px-6 pb-3 pt-1">
				<form name="searchForm">
					<input type="hidden" name="category" value="${param.category}">
					<div class="flex gap-2">
					    <div class="relative">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                                class="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-400">
                                <circle cx="11" cy="11" r="8"></circle>
                                <path d="m21 21-4.3-4.3"></path></svg>
                            <input type="text" name="kwd" value="${param.kwd}"
                                placeholder="장소명으로 검색"
                                class="w-full rounded-xl border border-slate-200 py-2.5 pl-10 pr-3 focus:outline-none focus:ring-2 focus:ring-sky-400">
						</div>
						<button type="button" class="rounded-xl px-4 py-2.5 font-semibold transition bg-sky-500 text-white hover:bg-sky-600"
						onclick="searchContent()">검색</button>
					</div>
				</form>
				<!-- 카테고리 탭바 -->
				<div class="category-tab-bar mt-3">
					<button class="category-tab ${empty param.category || param.category == 'all' ? 'active' : ''}"
					onclick="location.href='${ctx}/admin/contents?category=${'all'}';">전체</button>

					<!-- 컨텐츠 카테고리 조회해서 뿌림 -->
					<c:forEach var="cate" items="${cateList}">
						<button class="category-tab ${param.category == cate.contentTypeId ? 'active' : ''}"
						onclick="location.href='${ctx}/admin/contents?category=${cate.contentTypeId}';">${cate.contentDiv }</button>
					</c:forEach>
				</div>
			</div>

            <%-- 컨텐츠 목록 --%>
            <div class="overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm" style="min-height:80px">
                <table class="w-full text-sm text-slate-700">
                    <thead class="border-b border-slate-100 bg-slate-50 text-xs font-semibold uppercase tracking-wide text-slate-500">
                        <tr>
                            <th class="px-4 py-3 text-left">순번</th>
                            <th class="px-4 py-3 text-left">컨텐츠ID</th>
                            <th class="px-4 py-3 text-left">카테고리</th>
                            <th class="px-4 py-3 text-left">제목</th>
                            <th class="px-4 py-3 text-left">APIID</th>
                            <th class="px-4 py-3 text-left">리뷰수</th>
                            <th class="px-4 py-3 text-left">수정일</th>
                            <th class="px-4 py-3 text-left">관리</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <c:set var="startNum" value="${(page - 1) * 10}" />
                        <c:forEach var="c" items="${contentList}" varStatus="s">
                            <tr class="hover:bg-slate-50">
                                <td class="px-4 py-3 text-slate-400">${startNum + s.index + 1}</td>
                                <td class="px-4 py-3 text-slate-400">${c.contentId}</td>
                                <td class="px-4 py-3">
                                    <span class="rounded-full bg-sky-100 px-2 py-0.5 text-xs font-semibold text-sky-600">${c.category}</span>
                                </td>
                                <td class="max-w-xs px-4 py-3 font-semibold text-slate-900">
                                    <span class="line-clamp-1">${c.title}</span>
                                </td>
                                <td class="px-4 py-3">${c.apiId}</td>
                                <td class="px-4 py-3">${c.reviewCount}</td>
                                <td class="whitespace-nowrap px-4 py-3">${c.modifiedTime}</td>
                                <td class="px-4 py-3">
                                    <button onclick="location.href='${ctx}/admin/contents/${c.contentId}${query}${fn:contains(query, '?') ? '&' : '?'}page=${page}';"
                                            class="rounded-lg bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-200">
                                        상세보기
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty contentList}">
                            <tr>
                                <td colspan="7" class="py-12 text-center text-slate-400">컨텐츠가 없습니다.</td>
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
