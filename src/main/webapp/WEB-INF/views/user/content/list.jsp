<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="activePage" value="contents" />
<!DOCTYPE html>
<html lang="ko">
<head>
<%@ include file="/WEB-INF/views/common/head.jsp"%>
<title>트래블메이트 — 여행지 탐색</title>
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
		<%@ include file="/WEB-INF/views/common/sidebar_user.jsp"%>

		<main class="mx-auto w-full max-w-6xl flex-1 p-6">

			<div class="mb-6">
				<h1 class="text-2xl font-bold text-slate-900">여행지 탐색</h1>
				<p class="mt-1 text-sm text-slate-400">가고 싶은 장소를 찾아 여행 계획에 담아보세요</p>
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
					onclick="location.href='${ctx}/contents/list?category=${'all'}';">전체</button>

					<!-- 컨텐츠 카테고리 조회해서 뿌림 -->
					<c:forEach var="cate" items="${cateList}">
						<button class="category-tab ${param.category == cate.contentTypeId ? 'active' : ''}"
						onclick="location.href='${ctx}/contents/list?category=${cate.contentTypeId}';">${cate.contentDiv }</button>
					</c:forEach>
				</div>
			</div>
			<!-- 콘텐츠 그리드 -->
			<c:choose>
				<c:when test="${not empty contentList}">
					<div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
						<c:forEach var="c" items="${contentList}">
							<div
								class="group overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm transition hover:shadow-md">
								<!-- 썸네일 -->
								<div
									class="relative aspect-video w-full overflow-hidden bg-slate-100">
									<c:choose>
										<c:when test="${not empty c.firstImage}">
											<img src="${c.firstImage}" alt="${c.title}"
												class="h-full w-full object-cover">
										</c:when>
										<c:otherwise>
											<div
												class="flex h-full w-full items-center justify-center bg-slate-100">
												<i data-lucide="map-pin" class="h-9 w-9 text-slate-300"></i>
											</div>
										</c:otherwise>
									</c:choose>
									<span
										class="absolute right-2 top-2 rounded-full bg-white/90 px-2 py-0.5 text-xs font-semibold text-slate-600">
										${c.contentDiv} </span>
									<c:if test="${not empty c.eventStartDate}">
										<fmt:parseDate value="${c.eventStartDate}" var="startDate" pattern="yyyyMMdd"/>
										<fmt:parseDate value="${c.eventEndDate}" var="endDate" pattern="yyyyMMdd"/>
										<span
											class="absolute left-2 top-2 rounded-full bg-orange-100 px-2 py-0.5 text-xs font-semibold text-orange-600">
											<fmt:formatDate value="${startDate}" pattern="yy.MM.dd"/>
											~
											<fmt:formatDate value="${endDate}" pattern="yy.MM.dd"/>
											</span>
									</c:if>
								</div>
								<!-- 정보 -->
								<div class="p-4">
									<div class="flex items-start justify-between gap-2">
										<a href="${ctx}/contents/${c.contentId}${query}${fn:contains(query, '?') ? '&' : '?'}page=${page}"
											class="truncate font-semibold text-slate-900 hover:text-sky-600">${c.title}</a>
										<button
											class="heart-btn shrink-0 text-slate-300 transition hover:text-red-400 ${c.bookmark == 'Y' ? 'favorited' : ''}"
											data-content-id="${c.contentId}"
											onclick="toggleFavorite(this, ${c.contentId})">
											<i data-lucide="heart"
												class="h-5 w-5 ${c.bookmark == 'Y' ? 'fill-red-500 text-red-500' : ''}"></i>
										</button>
									</div>
									<c:if test="${not empty c.addr1 }">
										<p class="mt-1 flex items-center gap-1 text-sm text-slate-400">
											<i data-lucide="map-pin" class="h-4 w-4 shrink-0"></i> <span
												class="truncate">${c.addr1}</span>
										</p>
									</c:if>
									<div class="mt-2 flex items-center gap-1 text-sm">
										<i data-lucide="star"
											class="h-4 w-4 fill-amber-400 text-amber-400"></i> <span
											class="font-semibold text-slate-900">${c.avgRating}</span> <span
											class="text-slate-400">· 리뷰 ${c.reviewCount}</span>
									</div>
								</div>
							</div>
						</c:forEach>
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
				</c:when>

				<c:otherwise>
					<div
						class="flex flex-col items-center justify-center rounded-2xl border border-dashed border-slate-200 bg-white py-16 text-center">
						<i data-lucide="search" class="mb-4 h-10 w-10 text-slate-300"></i>
						<p class="whitespace-pre-line text-sm text-slate-400">검색 결과가 없어요&#10;다른 키워드로 검색해보세요</p>
					</div>
				</c:otherwise>
			</c:choose>
		</main>

	</div>

	<script>const ctx = '${ctx}';</script>
	<script src="${ctx}/dist/js/common.js"></script>
</body>
</html>
