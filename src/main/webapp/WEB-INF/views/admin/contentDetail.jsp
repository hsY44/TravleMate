<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx"        value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="contents"/>
<!DOCTYPE html>
<html lang="ko">
<head>
    <link rel="icon" href="data:;base64,iVBORw0KGgo=">
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 컨텐츠 상세</title>
    <link rel="stylesheet" href="${ctx}/dist/css/admin.css">
    <link rel="stylesheet" href="${ctx}/dist/css/user.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_admin.jsp" %>

    <main class="flex-1 p-6">
        <div class="mx-auto max-w-4xl">

            <!-- 헤더 -->
            <div class="mb-6 flex items-center justify-between">
                <a href="${ctx}/admin/contents?${query}"
                   class="flex items-center gap-1 text-sm text-slate-400 transition hover:text-slate-600">
                    <i data-lucide="arrow-left" class="h-4 w-4"></i> 목록으로
                </a>
                <h1 class="text-2xl font-bold text-slate-900">컨텐츠 상세 · ${content.title}</h1>
                <div class="flex gap-2">
                    <a href="${ctx}/admin/reviews?schType=contentId&kwd=${content.contentId}"
                       class="rounded-xl border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-50">
                        리뷰 관리
                    </a>
                </div>
            </div>

            <!-- 메인 이미지 갤러리 -->
            <div class="mb-6 overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
                <div class="relative aspect-video w-full overflow-hidden bg-slate-100">
                    <c:choose>
                        <c:when test="${not empty images}">
                            <c:forEach var="img" items="${images}" varStatus="s">
                                <img id="galleryImg${s.index}" src="${img.originImgUrl}"
                                     alt="${img.imgName}"
                                     class="absolute inset-0 h-full w-full object-cover transition-opacity duration-200 ${s.first ? '' : 'opacity-0'}">
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <div class="flex h-full w-full items-center justify-center bg-slate-100">
                                <i data-lucide="image" class="h-12 w-12 text-slate-300"></i>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
                <c:if test="${images.size() > 1}">
                    <div class="flex gap-2 p-3 overflow-x-auto no-scrollbar">
                        <c:forEach var="img" items="${images}" varStatus="s">
                            <div class="gallery-thumb h-16 w-16 shrink-0 ${s.first ? 'active' : ''}"
                                 data-index="${s.index}" onclick="selectGalleryImage(${s.index})">
                                <img src="${img.originImgUrl}" alt="${img.imgName}" class="h-full w-full object-cover">
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
            </div>

            <!-- 콘텐츠 정보 -->
            <div class="mb-6 rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
                <div class="flex items-start justify-between gap-4">
                    <div class="flex-1">
                        <div class="flex items-center gap-2">
                            <h1 class="text-xl font-bold text-slate-900">${content.title}</h1>
                            <span class="rounded-full bg-sky-100 px-2 py-0.5 text-xs font-semibold text-sky-600">${content.contentDiv}</span>
                        </div>
                        <div class="mt-1 flex items-center gap-1 text-sm">
                            <i data-lucide="star" class="h-4 w-4 fill-amber-400 text-amber-400"></i>
                            <span class="font-semibold text-slate-900">${content.avgRating}</span>
                            <span class="text-slate-400 review-count">· 리뷰 ${content.reviewCount}개</span>
                        </div>
                        <p class="mt-1.5 flex items-center gap-1.5 text-sm text-slate-400">
                            <i data-lucide="map-pin" class="h-4 w-4 shrink-0"></i>${content.addr1}
                            <c:if test="${not empty content.addr2 }">
                                <span>${content.addr2 }</span>
                            </c:if>
                        </p>
                        <p class="mt-1.5 flex items-center gap-1.5 text-sm text-slate-400">
                            <span>경도(X) ${content.mapX}</span>
                            <span>· 위도(Y) ${content.mapY}</span>
                        </p>
                        <c:if test="${not empty content.eventStartDate}">
                            <fmt:parseDate value="${content.eventStartDate}" var="startDate" pattern="yyyyMMdd"/>
                            <fmt:parseDate value="${content.eventEndDate}" var="endDate" pattern="yyyyMMdd"/>
                            <p class="mt-1 text-sm text-orange-500">
                                <i data-lucide="calendar" class="h-4 w-4 inline"></i>
                                <span>행사기간</span>
                                <fmt:formatDate value="${startDate}" pattern="yy.MM.dd"/>
                                ~
                                <fmt:formatDate value="${endDate}" pattern="yy.MM.dd"/>
                            </p>
                        </c:if>
                        <p class="mt-1.5 flex items-center gap-1.5 text-sm text-slate-400">
                            <span>등록일 ${content.createdTime }</span>
                        </p>
                        <p class="mt-1.5 flex items-center gap-1.5 text-sm text-slate-400">
                            <span>수정일 ${content.modifiedTime }</span>
                        </p>
                        <p class="mt-1.5 flex items-center gap-1.5 text-sm text-slate-400">
                            <span>APIID ${content.apiId}</span>
                        </p>
                    </div>
                </div>
            </div>

        </div>
    </main>
</div>

<script>const ctx = '${ctx}';</script>
<script src="${ctx}/dist/js/common.js"></script>
<script src="${ctx}/dist/js/contentDetail.js"></script>
</body>
</html>
