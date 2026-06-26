<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="contents"/>
<!DOCTYPE html>
<html lang="ko">
<head>
<%@ include file="/WEB-INF/views/common/head.jsp" %>
<title>트래블메이트 — ${content.title}</title>
<link rel="stylesheet" href="${ctx}/dist/css/user.css">
<script type="text/javascript">

	document.addEventListener('DOMContentLoaded', function() {
		getReviewList(0);
	});

    // 리뷰 조회
    async function getReviewList(page) {
        const url = "${ctx}/contents/review/list?page=" + page + "&contentId=${contentId}";

        try {
            const res = await fetch(url);

            if (res.ok) {
                const data = await res.json();
                renderReviewList(data);
            } else {
                showToast('리뷰를 불러오는 데 실패했습니다.', 2000, 'error');
            }
        } catch (error) {
            showToast('리뷰를 불러오는 데 실패했습니다.', 2000, 'error');
        }
    }

</script>
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_user.jsp" %>

    <main class="mx-auto w-full max-w-4xl flex-1 p-6">

        <!-- 뒤로가기 -->
        <a href="${ctx}/contents/list?${query}" class="mb-4 flex items-center gap-2 text-sm text-slate-400 hover:text-slate-600">
            <i data-lucide="arrow-left" class="h-4 w-4"></i> 목록으로
        </a>

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
                    <c:if test="${not empty content.eventStartDate}">
                        <fmt:parseDate value="${content.eventStartDate}" var="startDate" pattern="yyyyMMdd"/>
                        <fmt:parseDate value="${content.eventEndDate}" var="endDate" pattern="yyyyMMdd"/>
                        <p class="mt-1 text-sm text-orange-500">
                            <i data-lucide="calendar" class="h-4 w-4 inline"></i>
                            <fmt:formatDate value="${startDate}" pattern="yy.MM.dd"/>
                            ~
							<fmt:formatDate value="${endDate}" pattern="yy.MM.dd"/>
                        </p>
                    </c:if>
                </div>
                <!-- 즐겨찾기 버튼 -->
                <c:choose>
                	<c:when test="${not empty sessionScope.memberNo }">
			                <button id="favBtn"
			                        class="heart-btn shrink-0 text-slate-300 hover:text-red-400 ${content.bookmark == 'Y' ? 'favorited' : ''}"
			                        onclick="toggleDetailFavorite()">
			                    <i data-lucide="heart" class="h-6 w-6 ${content.bookmark == 'Y' ? 'fill-red-500 text-red-500' : ''}"></i>
			                </button>
                	</c:when>
                	<c:otherwise>
                		<button id="favBtn"
			                    class="heart-btn shrink-0 text-slate-300 hover:text-red-400"
			                    onclick="loginToast()">
			            	<i data-lucide="heart" class="h-6 w-6"></i>
						</button>
                	</c:otherwise>
                </c:choose>
            </div>
            <!-- 계획 담기 버튼 -->
            <c:if test="${not empty sessionScope.memberNo}">
                <div class="mt-4 flex gap-2">
                    <button onclick="openModal('addToPlanModal')"
                            class="flex items-center gap-1.5 rounded-xl bg-sky-500 px-4 py-2 text-sm font-semibold text-white transition hover:bg-sky-600">
                        <i data-lucide="plus" class="h-4 w-4"></i> 여행 일정에 담기
                    </button>
                </div>
            </c:if>
        </div>
        <!-- 리뷰 섹션 -->
        <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
            <div class="mb-4 flex items-center justify-between">
                <h2 class="font-semibold text-slate-900 review-count">리뷰 ${content.reviewCount}개</h2>
                <c:if test="${not empty sessionScope.memberNo}">
                    <button onclick="openModal('writeReviewModal')"
                            class="flex items-center gap-1.5 rounded-xl bg-sky-500 px-3 py-2 text-sm font-semibold text-white transition hover:bg-sky-600">
                        <i data-lucide="pencil" class="h-4 w-4"></i> 리뷰 작성
                    </button>
                </c:if>
            </div>
            <div id="reviewSection" data-current-member-no="${sessionScope.memberNo}">
                <input type="hidden" id="currentReviewPage" value="0">
                <div id="reviewListContainer"></div>
            </div>
            <div id="reviewPaginationContainer"></div>

        </div>
    </main>

</div>

<!-- 리뷰 작성/수정 모달 -->
<div id="writeReviewModal" class="modal-backdrop hidden" onclick="closeModal('writeReviewModal')">
    <div class="modal-box" onclick="event.stopPropagation()">
        <div class="mb-5 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-slate-900" id="reviewModalTitle">리뷰 작성</h2>
            <button onclick="closeModal('writeReviewModal')" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>
        <form name="reviewForm">
	        <input type="hidden" id="editReviewId">
	        <div class="mb-3">
	            <label class="mb-2 block text-sm font-semibold text-slate-900">별점</label>
	            <div class="star-rating" id="starRating">
	                <input type="radio" name="rating" id="star5" value="5"><label for="star5"></label>
	                <input type="radio" name="rating" id="star4" value="4"><label for="star4"></label>
	                <input type="radio" name="rating" id="star3" value="3"><label for="star3"></label>
	                <input type="radio" name="rating" id="star2" value="2"><label for="star2"></label>
	                <input type="radio" name="rating" id="star1" value="1"><label for="star1"></label>
	            </div>
	        </div>
	        <div>
	            <label class="mb-1.5 block text-sm font-semibold text-slate-900">내용</label>
	            <textarea id="reviewContent" rows="4" placeholder="여행 경험을 공유해주세요"
	                      class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400"></textarea>
	        </div>
	        <div class="mt-4 flex justify-end gap-2">
	            <button type="reset" onclick="closeModal('writeReviewModal')"
	                    class="rounded-xl bg-slate-100 px-4 py-2.5 font-semibold text-slate-600 transition hover:bg-slate-200">취소</button>
	            <button type="button" onclick="saveReview()"
	                    class="rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">저장</button>
	        </div>
        </form>
    </div>
</div>

<!-- 신고 모달 -->
<div id="reportModal" class="modal-backdrop hidden" onclick="closeModal('reportModal')">
    <div class="modal-box" onclick="event.stopPropagation()">
        <div class="mb-5 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-slate-900">리뷰 신고</h2>
            <button onclick="closeModal('reportModal')" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>
        <form name="reportForm">
            <input type="hidden" id="reportReviewId">
            <label class="mb-1.5 block text-sm font-semibold text-slate-900">신고 유형</label>
            <select id="reportCategory"
                    class="mb-3 w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                <c:forEach var="cat" items="${reportCategories}">
                    <option value="${cat.reportTypeCd}">${cat.reportTypeNm}</option>
                </c:forEach>
            </select>
            <label class="mb-1.5 block text-sm font-semibold text-slate-900">신고 내용</label>
            <textarea id="reportContent" rows="3" placeholder="신고 사유를 입력해주세요"
                      class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400"></textarea>
        </form>
        <div class="mt-4 flex justify-end gap-2">
            <button onclick="closeModal('reportModal')"
                    class="rounded-xl bg-slate-100 px-4 py-2.5 font-semibold text-slate-600 transition hover:bg-slate-200">취소</button>
            <button onclick="submitReport()"
                    class="rounded-xl bg-red-500 px-4 py-2.5 font-semibold text-white transition hover:bg-red-600">신고하기</button>
        </div>
    </div>
</div>

<!-- 계획 담기 모달 -->
<div id="addToPlanModal" class="modal-backdrop hidden" onclick="closeModal('addToPlanModal')">
    <div class="modal-box max-w-[30rem]" onclick="event.stopPropagation()" >
        <div class="mb-5 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-slate-900">여행 일정에 담기</h2>
            <button onclick="closeModal('addToPlanModal')" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>
        <div class="flex flex-col gap-2" id="myPlanList">
            <c:choose>
                <c:when test="${not empty myPlans and myPlans.size() > 0}">
                    <c:forEach var="item" items="${myPlans}">
                        <c:set var="p" value="${item.plan}" />
                        <div class="flex items-center justify-between w-full rounded-xl border border-slate-200 px-4 py-3 text-sm hover:bg-slate-50">
                            <div class="flex flex-col">
                                <span class="font-semibold text-slate-900">${p.title}</span>
                                <span class="text-xs text-slate-400 mt-0.5">${p.startDate} ~ ${p.endDate} (${p.dayCount}일)</span>
                            </div>
                            <div class="flex items-center gap-2">
                                <select id="daySelect_${p.id}" class="rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-sky-400">
                                    <c:forEach var="date" items="${item.dateList}" varStatus="status">
                                        <option value="${date}">
                                            ${fn:substring(date, 5, 10)} (${status.count}일차)
                                        </option>
                                    </c:forEach>
                                </select>
                                <button onclick="addToPlanFromBtn(this)"
                                        data-plan-id="${p.id}"
                                        data-content-id="${content.contentId}"
                                        data-title="${fn:escapeXml(content.title)}"
                                        class="flex items-center gap-1.5 rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="h-3.5 w-3.5">
                                        <path d="M5 12h14"></path>
                                        <path d="M12 5v14"></path>
                                    </svg>
                                    담기
                                </button>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <p class="py-4 text-center text-sm text-slate-400">보유한 여행 계획이 없습니다.</p>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>

<!-- 확인 모달 -->
<div id="confirmModal" class="modal-backdrop hidden" onclick="closeModal('confirmModal')">
    <div class="modal-box" onclick="event.stopPropagation()">
        <p id="confirmMessage" class="text-sm text-slate-600 mb-5"></p>
        <div class="flex justify-end gap-2">
            <button onclick="closeModal('confirmModal')"
                    class="rounded-xl bg-slate-100 px-4 py-2.5 font-semibold text-slate-600">취소</button>
            <button id="confirmOkBtn"
                    class="rounded-xl bg-red-500 px-4 py-2.5 font-semibold text-white">확인</button>
        </div>
    </div>
</div>

<script>
const ctx = '${ctx}';
const contentId = ${content.contentId};

function addToPlanFromBtn(btn) {
    addToPlan(btn.dataset.planId, btn.dataset.contentId, btn.dataset.title);
}
</script>
<script src="${ctx}/dist/js/common.js"></script>
<script src="${ctx}/dist/js/contentDetail.js"></script>
</body>
</html>
