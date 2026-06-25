<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<c:set var="activePage" value="mypage"/>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 마이페이지</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/user.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_user.jsp" %>

    <main class="mx-auto w-full max-w-5xl flex-1 p-6">
        <h1 class="mb-6 text-2xl font-bold text-slate-900">마이페이지</h1>

        <div class="flex flex-col gap-6 md:flex-row">

            <!--
                사이드 탭 메뉴
                data-mytab: JS(switchMypageTab)에서 현재 탭 식별에 사용
                모바일: flex-row (가로 나열), md 이상: flex-col (세로 목록)
            -->
            <nav class="flex shrink-0 gap-1 md:w-44 md:flex-col">
                <button class="mypage-tab active" data-mytab="profile"   onclick="switchMypageTab('profile')">
                    <i data-lucide="user-cog"       class="h-5 w-5"></i> 내 정보 수정
                </button>
                <button class="mypage-tab" data-mytab="favorites"  onclick="switchMypageTab('favorites')">
                    <i data-lucide="heart"          class="h-5 w-5"></i> 즐겨찾기
                </button>
                <button class="mypage-tab" data-mytab="plans"    onclick="switchMypageTab('plans')">
                    <i data-lucide="map"            class="h-5 w-5"></i> 여행 계획
                </button>
                <button class="mypage-tab" data-mytab="reviews"   onclick="switchMypageTab('reviews')">
                    <i data-lucide="star"           class="h-5 w-5"></i> 리뷰 목록
                </button>
                <button class="mypage-tab" data-mytab="inquiries"  onclick="switchMypageTab('inquiries')">
                    <i data-lucide="message-square" class="h-5 w-5"></i> 문의 내역
                </button>
                <button class="mypage-tab" data-mytab="invitations" onclick="switchMypageTab('invitations')">
                    <i data-lucide="mail" class="h-5 w-5"></i> 받은 초대
                </button>
            </nav>

            <!-- 탭 패널 영역 -->
            <div class="flex-1 min-w-0">

                <!-- 내 정보 수정 탭  -->
                <div id="panelProfile">
                    <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
                        <h2 class="mb-5 font-semibold text-slate-900">내 정보 수정</h2>

                        <form id="profileForm" class="flex flex-col gap-4">
                            <div>
                                <label class="mb-1.5 block text-sm font-semibold text-slate-900">이름</label>
                                <input type="text" id="profileName" value="${member.name}"
                                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                            </div>
                            <div>
                                <label class="mb-1.5 block text-sm font-semibold text-slate-900">닉네임</label>
                                <div class="flex gap-2">
                                    <input type="text" id="profileNickname" value="${member.nickname}"
                                           class="flex-1 rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                                    <!-- 닉네임 중복 확인 (AJAX: checkProfileNickname()) — 자기 자신 제외 -->
                                    <button type="button" onclick="checkProfileNickname()"
                                            class="rounded-xl bg-slate-100 px-4 py-2.5 font-semibold text-slate-600 hover:bg-slate-200 transition">중복확인</button>
                                </div>
                                <p id="nicknameMsg" class="mt-1 hidden text-sm"></p>
                            </div>
                            <div>
                                <label class="mb-1.5 block text-sm font-semibold text-slate-900">이메일</label>
                                <input type="email" id="profileEmail" value="${member.email}"
                                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                            </div>
                            <div>
                                <label class="mb-1.5 block text-sm font-semibold text-slate-900">휴대폰번호</label>
                                <!-- MemberVo 필드명: phoneNo -->
                                <input type="tel" id="profilePhone" value="${member.phoneNo}"
                                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                            </div>
                            <div>
                                <!-- 비밀번호 미입력 시 변경하지 않음 (JS에서 빈 값이면 요청 body에서 제외) -->
                                <label class="mb-1.5 block text-sm font-semibold text-slate-900">새 비밀번호 <span class="text-xs font-normal text-slate-400">(변경 시에만 입력)</span></label>
                                <input type="password" id="profilePw" placeholder="새 비밀번호"
                                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                            </div>
                            <div class="flex justify-between pt-2">
                                <button type="button" onclick="openModal('withdrawModal')"
                                        class="text-sm text-slate-400 hover:text-red-400 transition">회원 탈퇴</button>
                                <button type="button" onclick="saveProfile()"
                                        class="rounded-xl bg-sky-500 px-5 py-2.5 font-semibold text-white transition hover:bg-sky-600">저장</button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- 즐겨찾기 탭 -->
                <div id="panelFavorites" class="hidden">
                    <c:choose>
                        <c:when test="${not empty favorites}">
                            <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
                                <c:forEach var="fav" items="${favorites}">
                                    <a href="${pageContext.request.contextPath}/contents/${fav.contentId}"
                                       class="flex items-center gap-3 rounded-2xl border border-slate-200 bg-white p-4 shadow-sm hover:shadow-md transition">
                                        <div class="flex h-14 w-14 shrink-0 items-center justify-center rounded-xl bg-slate-100">
                                            <i data-lucide="map-pin" class="h-6 w-6 text-slate-300"></i>
                                        </div>
                                        <div class="min-w-0">
                                            <p class="truncate font-semibold text-slate-900">${fav.title}</p>
                                            <p class="text-xs text-slate-400">${fav.contentDiv}</p>
                                        </div>
                                    </a>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="flex flex-col items-center justify-center rounded-2xl border border-dashed border-slate-200 bg-white py-16 text-center">
                                <i data-lucide="heart" class="mb-4 h-10 w-10 text-slate-300"></i>
                                <p class="text-sm text-slate-400">즐겨찾기한 장소가 없습니다</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!--  여행 계획 탭  -->
                <div id="panelPlans" class="hidden">
                    <div class="mb-4 flex justify-end">
                        <a href="${pageContext.request.contextPath}/plans"
                           class="flex items-center gap-1.5 rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">
                            <i data-lucide="plus" class="h-4 w-4"></i> 새 여행 계획
                        </a>
                    </div>
                    <c:choose>
                        <c:when test="${not empty plans}">
                            <div class="flex flex-col gap-3">
                                <c:forEach var="plan" items="${plans}">
                                    <a href="${pageContext.request.contextPath}/plans/${plan.travelPlanNo}"
                                       class="flex items-center justify-between rounded-2xl border border-slate-200 bg-white p-4 shadow-sm hover:shadow-md transition">
                                        <div class="min-w-0 flex-1">
                                            <div class="flex items-center gap-2">
                                                <span class="rounded-full bg-sky-100 px-2 py-0.5 text-xs font-semibold text-sky-600">${plan.travelThemeNm}</span>
                                                <span class="truncate font-semibold text-slate-900">${plan.travelName}</span>
                                            </div>
                                            <p class="mt-1 text-xs text-slate-400">${plan.travelStartDt} ~ ${plan.travelEndDt}</p>
                                        </div>
                                        <i data-lucide="chevron-right" class="ml-3 h-4 w-4 shrink-0 text-slate-300"></i>
                                    </a>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="flex flex-col items-center justify-center rounded-2xl border border-dashed border-slate-200 bg-white py-16 text-center">
                                <i data-lucide="map" class="mb-4 h-10 w-10 text-slate-300"></i>
                                <p class="mb-3 text-sm text-slate-400">아직 여행 계획이 없습니다</p>
                                <a href="${pageContext.request.contextPath}/plans"
                                   class="rounded-xl bg-sky-500 px-4 py-2 text-sm font-semibold text-white transition hover:bg-sky-600">
                                    계획 만들기
                                </a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- 리뷰 목록 탭 -->
                <div id="panelReviews" class="hidden">
                    <c:choose>
                        <c:when test="${not empty reviews}">
                            <div class="flex flex-col gap-3">
                                <c:forEach var="review" items="${reviews}">
                                    <div class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
                                        <div class="flex items-start justify-between gap-2">
                                            <a href="${pageContext.request.contextPath}/contents/${review.contentId}"
                                               class="min-w-0 flex-1 truncate font-semibold text-slate-900 hover:text-sky-600 transition">
                                                ${review.title}
                                            </a>
                                            <!-- 별점 표시 (rating: 1~5) -->
                                            <div class="flex shrink-0 items-center gap-0.5 text-amber-400">
                                                <c:forEach begin="1" end="${review.rating}" var="s">
                                                    <i data-lucide="star" class="h-4 w-4 fill-current"></i>
                                                </c:forEach>
                                                <c:forEach begin="${review.rating + 1}" end="5" var="s">
                                                    <i data-lucide="star" class="h-4 w-4 text-slate-200"></i>
                                                </c:forEach>
                                            </div>
                                        </div>
                                        <p class="mt-2 text-sm text-slate-600">${review.reviewComment}</p>
                                        <p class="mt-1 text-xs text-slate-400">${review.createDt}</p>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="flex flex-col items-center justify-center rounded-2xl border border-dashed border-slate-200 bg-white py-16 text-center">
                                <i data-lucide="star" class="mb-4 h-10 w-10 text-slate-300"></i>
                                <p class="text-sm text-slate-400">작성한 리뷰가 없습니다</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!--  문의 내역 탭  -->
                <div id="panelInquiries" class="hidden">
                    <div class="mb-4 flex items-center justify-between">
                        <!-- 전체 목록은 /qna/list (페이징 포함 독립 페이지) -->
                        <a href="${pageContext.request.contextPath}/qna/list"
                           class="text-sm text-slate-400 hover:text-sky-600 transition">전체 보기</a>
                        <button onclick="openModal('writeInquiryModal')"
                                class="flex items-center gap-1.5 rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">
                            <i data-lucide="plus" class="h-4 w-4"></i> 문의하기
                        </button>
                    </div>
                    <!-- 최근 5건만 표시 (전체는 /qna/list) -->
                    <c:choose>
                        <c:when test="${not empty inquiries}">
                            <div class="flex flex-col gap-3">
                                <c:forEach var="inq" items="${inquiries}">
                                    <div class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
                                        <div class="flex items-start justify-between gap-2">
                                            <div class="flex-1 min-w-0">
                                                <div class="flex items-center gap-2">
                                                    <span class="rounded-full bg-sky-100 px-2 py-0.5 text-xs font-semibold text-sky-600">${inq.qnaTypeNm}</span>
                                                    <span class="truncate text-sm font-semibold text-slate-900">${inq.qnaTitle}</span>
                                                </div>
                                                <p class="mt-1 text-xs text-slate-400">${inq.createDt}</p>
                                            </div>
                                            <!--
                                                답변 상태 뱃지
                                                STATUS_CD: ST001(접수/대기), ST002(답변완료)
                                            -->
                                            <span class="shrink-0 rounded-full px-2 py-0.5 text-xs font-semibold
                                                ${inq.statusCd eq 'ST002' ? 'bg-emerald-100 text-emerald-600' : 'bg-amber-100 text-amber-600'}">
                                                ${inq.statusCd eq 'ST002' ? '답변 완료' : '답변 대기'}
                                            </span>
                                        </div>
                                        <c:if test="${inq.statusCd eq 'ST002' and not empty inq.ansContent}">
                                            <div class="mt-3 rounded-xl border border-slate-100 bg-slate-50 p-3 text-sm text-slate-600">
                                                <p class="mb-1 text-xs font-semibold text-slate-400">관리자 답변</p>
                                                ${inq.ansContent}
                                            </div>
                                        </c:if>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="flex flex-col items-center justify-center rounded-2xl border border-dashed border-slate-200 bg-white py-16 text-center">
                                <i data-lucide="message-square" class="mb-4 h-10 w-10 text-slate-300"></i>
                                <p class="text-sm text-slate-400">문의 내역이 없습니다</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- 받은 초대 탭 -->
                <div id="panelInvitations" class="hidden">
                    <c:choose>
                        <c:when test="${not empty receivedInvitations}">
                            <div class="flex flex-col gap-3">
                                <c:forEach var="inv" items="${receivedInvitations}">
                                    <div class="rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
                                        <div class="flex items-center justify-between gap-2">
                                            <div class="min-w-0 flex-1">
                                                <span class="truncate font-semibold text-slate-900">${inv.planTitle}</span>
                                                <p class="mt-1 text-xs text-slate-400">${inv.hostNickname} 님의 초대 · ${inv.createDt}</p>
                                            </div>
                                            <div class="flex shrink-0 gap-2">
                                                <button onclick="respondInvitation(${inv.invitationNo}, 'accept')"
                                                        class="rounded-xl bg-sky-500 px-3 py-1.5 text-sm font-semibold text-white transition hover:bg-sky-600">수락</button>
                                                <button onclick="respondInvitation(${inv.invitationNo}, 'decline')"
                                                        class="rounded-xl bg-slate-100 px-3 py-1.5 text-sm font-semibold text-slate-600 transition hover:bg-slate-200">거절</button>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="flex flex-col items-center justify-center rounded-2xl border border-dashed border-slate-200 bg-white py-16 text-center">
                                <i data-lucide="mail" class="mb-4 h-10 w-10 text-slate-300"></i>
                                <p class="text-sm text-slate-400">받은 초대가 없습니다</p>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>

            </div>
        </div>
    </main>
</div>

<!-- 문의하기 모달 -->
<div id="writeInquiryModal" class="modal-backdrop hidden" onclick="closeModal('writeInquiryModal')">
    <div class="modal-box" onclick="event.stopPropagation()">
        <div class="mb-5 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-slate-900">문의하기</h2>
            <button onclick="closeModal('writeInquiryModal')" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>
        <div class="flex flex-col gap-3">
            <div>
                <label class="mb-1.5 block text-sm font-semibold text-slate-900">카테고리</label>
                <!-- inquiryCategories: Task 8 에서 Controller → Model 에 담을 QNA_TYPE 목록 -->
                <select id="inqCategory"
                        class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                    <c:forEach var="cat" items="${inquiryCategories}">
                        <option value="${cat.qnaTypeCd}">${cat.qnaTypeNm}</option>
                    </c:forEach>
                </select>
            </div>
            <div>
                <label class="mb-1.5 block text-sm font-semibold text-slate-900">제목</label>
                <input type="text" id="inqTitle" placeholder="문의 제목"
                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
            </div>
            <div>
                <label class="mb-1.5 block text-sm font-semibold text-slate-900">내용</label>
                <textarea id="inqContent" rows="4" placeholder="문의 내용을 입력해주세요"
                          class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400"></textarea>
            </div>
            <div class="mt-2 flex justify-end gap-2">
                <button onclick="closeModal('writeInquiryModal')"
                        class="rounded-xl bg-slate-100 px-4 py-2.5 font-semibold text-slate-600 transition hover:bg-slate-200">취소</button>
                <button onclick="submitInquiry()"
                        class="rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">등록</button>
            </div>
        </div>
    </div>
</div>

<!-- 회원 탈퇴 확인 모달 -->
<div id="withdrawModal" class="modal-backdrop hidden" onclick="closeModal('withdrawModal')">
    <div class="modal-box" onclick="event.stopPropagation()">
        <div class="mb-5 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-slate-900">회원 탈퇴</h2>
            <button onclick="closeModal('withdrawModal')" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>
        <p class="mb-4 text-sm text-slate-600">탈퇴 시 모든 정보가 삭제되며 복구가 불가능합니다.<br>계속하려면 현재 비밀번호를 입력해주세요.</p>
        <input type="password" id="withdrawPw" placeholder="현재 비밀번호"
               class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-red-400">
        <p id="withdrawMsg" class="mt-1 hidden text-sm text-red-400"></p>
        <div class="mt-4 flex justify-end gap-2">
            <button onclick="closeModal('withdrawModal')"
                    class="rounded-xl bg-slate-100 px-4 py-2.5 font-semibold text-slate-600 transition hover:bg-slate-200">취소</button>
            <button onclick="submitWithdraw()"
                    class="rounded-xl bg-red-500 px-4 py-2.5 font-semibold text-white transition hover:bg-red-600">탈퇴하기</button>
        </div>
    </div>
</div>

<script>const ctx = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/dist/js/common.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/mypage.js"></script>
<script>
// 초대 수락·거절 — action: 'accept' | 'decline'
function respondInvitation(invitationNo, action) {
    fetch(ctx + '/invitations/' + invitationNo + '/' + action, { method: 'POST' })
        .then(function(r) {
            if (r.ok) { location.reload(); }
            else { showToast('처리에 실패했습니다.', 2000, 'error'); }
        });
}
</script>
</body>
</html>
