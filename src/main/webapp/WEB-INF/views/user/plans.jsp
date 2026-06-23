<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx"        value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="plans"/>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 여행계획</title>
    <link rel="stylesheet" href="${ctx}/dist/css/user.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_user.jsp" %>

    <main class="mx-auto w-full max-w-6xl flex-1 p-6">

        <!-- 헤더 -->
        <div class="mb-6 flex items-start justify-between gap-4">
            <div>
                <h1 class="text-2xl font-bold text-slate-900">여행 계획</h1>
                <p class="mt-1 text-sm text-slate-400">함께 떠날 여행을 계획하고 친구를 초대하세요</p>
            </div>
            <button onclick="openModal('newPlanModal')"
                    class="flex items-center gap-1.5 rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">
                <i data-lucide="plus" class="h-4 w-4"></i> 새 계획 만들기
            </button>
        </div>

        <!--
            탭: 내 계획 / 참여 중
            data-tab: JS(switchPlanTab)에서 현재 활성 탭 식별에 사용
        -->
        <div class="mb-5 flex gap-1 border-b border-slate-200" id="planTabs">
            <button data-tab="my"
                    class="tab-btn active px-4"
                    onclick="switchPlanTab('my')">내 계획</button>
            <button data-tab="joined"
                    class="tab-btn px-4"
                    onclick="switchPlanTab('joined')">참여 중</button>
        </div>

        <!-- 필터 -->
        <form id="filterForm" action="${ctx}/plans" method="get"
              class="mb-5 flex flex-wrap items-end gap-3 rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
            <!--
                tab 값을 hidden으로 유지: 필터 검색 후에도 현재 탭(내 계획/참여 중) 유지
                JS(switchPlanTab)에서 filterTab 값도 함께 변경
            -->
            <input type="hidden" name="tab" id="filterTab" value="${param.tab eq 'joined' ? 'joined' : 'my'}">
            <div class="flex flex-col gap-1">
                <label class="text-xs font-semibold text-slate-400">테마</label>
                <select name="theme"
                        class="rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-sky-400">
                    <option value="">전체</option>
                    <c:forEach var="t" items="${themes}">
                        <option value="${t}" ${param.theme eq t ? 'selected' : ''}>${t}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="flex flex-col gap-1">
                <label class="text-xs font-semibold text-slate-400">시작일</label>
                <input type="date" name="startDate" value="${param.startDate}"
                       class="rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-sky-400">
            </div>
            <div class="flex flex-col gap-1">
                <label class="text-xs font-semibold text-slate-400">종료일</label>
                <input type="date" name="endDate" value="${param.endDate}"
                       class="rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-sky-400">
            </div>
            <button type="submit"
                    class="flex items-center gap-1.5 rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">
                <i data-lucide="search" class="h-4 w-4"></i> 검색
            </button>
        </form>

        <!--
            내 계획 목록
            data-panel="my": JS에서 탭 전환 시 패널 식별
            초기 표시 여부: param.tab이 joined이면 hidden, 아니면 표시
        -->
        <div id="panelMy" data-panel="my" class="${param.tab eq 'joined' ? 'hidden' : ''}">
            <c:choose>
                <c:when test="${not empty myPlans}">
                    <div class="grid grid-cols-1 gap-4 lg:grid-cols-2">
                        <c:forEach var="plan" items="${myPlans}">
                            <a href="${ctx}/plans/${plan.id}"
                               class="flex cursor-pointer gap-4 rounded-2xl border border-slate-200 bg-white p-4 shadow-sm transition hover:shadow-md">
                                <div class="plan-thumb">
                                    <i data-lucide="map-pin" class="h-8 w-8 text-slate-300"></i>
                                </div>
                                <div class="flex min-w-0 flex-1 flex-col">
                                    <div class="flex items-center gap-2">
                                        <h3 class="truncate font-semibold text-slate-900">${plan.title}</h3>
                                        <span class="shrink-0 rounded-full bg-sky-100 px-2 py-0.5 text-xs text-sky-600">${plan.theme}</span>
                                    </div>
                                    <div class="mt-1 flex items-center gap-1.5 text-sm text-slate-400">
                                        <i data-lucide="calendar-days" class="h-4 w-4"></i>
                                        ${plan.startDate} ~ ${plan.endDate}
                                    </div>
                                    <p class="mt-2 line-clamp-2 text-sm text-slate-500">${plan.overview}</p>
                                    <div class="mt-auto flex items-center justify-between pt-3">
                                        <div class="flex items-center gap-3 text-sm text-slate-400">
                                            <span class="flex items-center gap-1">
                                                <i data-lucide="users" class="h-4 w-4"></i> ${plan.guestCount}명
                                            </span>
                                            <span>· 편집 ${plan.lastEditedAt}</span>
                                        </div>
                                        <span class="text-sm font-semibold text-sky-500">상세보기</span>
                                    </div>
                                </div>
                            </a>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <!-- 빈 상태(Empty State) UI -->
                    <div class="flex flex-col items-center justify-center rounded-2xl border border-dashed border-slate-200 bg-white py-16 text-center">
                        <i data-lucide="map-pin" class="mb-4 h-10 w-10 text-slate-300"></i>
                        <!--
                            &#10;: HTML 개행 문자 (LF)
                            whitespace-pre-line: CSS에서 \n을 줄바꿈으로 처리
                        -->
                        <p class="whitespace-pre-line text-sm text-slate-400">아직 만든 여행 계획이 없어요&#10;첫 계획을 만들어 보세요!</p>
                        <button onclick="openModal('newPlanModal')"
                                class="mt-5 rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">
                            새 계획 만들기
                        </button>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- 참여 중 목록 -->
        <div id="panelJoined" data-panel="joined" class="${param.tab eq 'joined' ? '' : 'hidden'}">
            <div class="mb-4 flex justify-end">
                <button onclick="openModal('inviteModal')"
                        class="flex items-center gap-1.5 rounded-xl border border-sky-500 px-4 py-2.5 font-semibold text-sky-500 transition hover:bg-sky-50">
                    <i data-lucide="ticket" class="h-4 w-4"></i> 초대 코드 입력
                </button>
            </div>
            <c:choose>
                <c:when test="${not empty joinedPlans}">
                    <div class="grid grid-cols-1 gap-4 lg:grid-cols-2">
                        <c:forEach var="plan" items="${joinedPlans}">
                            <a href="${ctx}/plans/${plan.id}"
                               class="flex cursor-pointer gap-4 rounded-2xl border border-slate-200 bg-white p-4 shadow-sm transition hover:shadow-md">
                                <div class="plan-thumb">
                                    <i data-lucide="map-pin" class="h-8 w-8 text-slate-300"></i>
                                </div>
                                <div class="flex min-w-0 flex-1 flex-col">
                                    <div class="flex items-center gap-2">
                                        <h3 class="truncate font-semibold text-slate-900">${plan.title}</h3>
                                        <span class="shrink-0 rounded-full bg-sky-100 px-2 py-0.5 text-xs text-sky-600">${plan.theme}</span>
                                    </div>
                                    <div class="mt-1 flex items-center gap-1.5 text-sm text-slate-400">
                                        <i data-lucide="calendar-days" class="h-4 w-4"></i>
                                        ${plan.startDate} ~ ${plan.endDate}
                                    </div>
                                    <p class="mt-2 line-clamp-2 text-sm text-slate-500">${plan.overview}</p>
                                    <div class="mt-auto flex items-center justify-between pt-3">
                                        <div class="flex items-center gap-3 text-sm text-slate-400">
                                            <span class="flex items-center gap-1">
                                                <i data-lucide="users" class="h-4 w-4"></i> ${plan.guestCount}명
                                            </span>
                                            <span>· 편집 ${plan.lastEditedAt}</span>
                                        </div>
                                        <span class="text-sm font-semibold text-sky-500">상세보기</span>
                                    </div>
                                </div>
                            </a>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="flex flex-col items-center justify-center rounded-2xl border border-dashed border-slate-200 bg-white py-16 text-center">
                        <i data-lucide="ticket" class="mb-4 h-10 w-10 text-slate-300"></i>
                        <p class="whitespace-pre-line text-sm text-slate-400">참여 중인 여행 계획이 없어요&#10;초대 코드로 참여해보세요!</p>
                        <button onclick="openModal('inviteModal')"
                                class="mt-5 rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">
                            초대 코드 입력
                        </button>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

</div>

<!-- 새 계획 만들기 모달 -->
<div id="newPlanModal" class="modal-backdrop hidden" onclick="closeModal('newPlanModal')">
    <div class="modal-box" onclick="event.stopPropagation()">
        <div class="mb-5 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-slate-900">새 여행 계획</h2>
            <button onclick="closeModal('newPlanModal')" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>
        <form id="newPlanForm" class="flex flex-col gap-3">
            <div>
                <label class="mb-1.5 block text-sm font-semibold text-slate-900">여행 제목</label>
                <input type="text" id="newPlanTitle" placeholder="여행 제목을 입력하세요"
                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
            </div>
            <div>
                <label class="mb-1.5 block text-sm font-semibold text-slate-900">테마</label>
                <select id="newPlanTheme"
                        class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                    <c:forEach var="t" items="${themes}">
                        <option value="${t}">${t}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="flex gap-2">
                <div class="flex-1">
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">시작일</label>
                    <input type="date" id="newPlanStart"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                </div>
                <div class="flex-1">
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">종료일</label>
                    <input type="date" id="newPlanEnd"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                </div>
            </div>
            <div>
                <label class="mb-1.5 block text-sm font-semibold text-slate-900">개요</label>
                <textarea id="newPlanOverview" rows="3" placeholder="여행 개요를 간략히 입력하세요"
                          class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400"></textarea>
            </div>
            <div class="mt-2 flex justify-end gap-2">
                <!-- type="button": form 태그 내에서 submit 방지 -->
                <button type="button" onclick="closeModal('newPlanModal')"
                        class="rounded-xl bg-slate-100 px-4 py-2.5 font-semibold text-slate-600 transition hover:bg-slate-200">취소</button>
                <button type="button" onclick="submitNewPlan()"
                        class="rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">만들기</button>
            </div>
        </form>
    </div>
</div>

<!-- 초대 코드 입력 모달 -->
<div id="inviteModal" class="modal-backdrop hidden" onclick="closeModal('inviteModal')">
    <div class="modal-box" onclick="event.stopPropagation()">
        <div class="mb-5 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-slate-900">초대 코드 입력</h2>
            <button onclick="closeModal('inviteModal')" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>
        <p class="mb-3 text-sm text-slate-400">호스트에게 받은 16자리 초대 코드를 입력하세요</p>
        <!--
            font-mono: 고정폭 폰트 (코드 가독성)
            tracking-widest: 글자 간격 최대로 벌려 코드 입력처럼 보이게
            maxlength="16": 입력 글자 수 제한
        -->
        <input id="inviteCodeInput" maxlength="16" placeholder="ABCD1234EFGH5678"
               class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-center font-mono tracking-widest focus:outline-none focus:ring-2 focus:ring-sky-400">
        <!-- 현재 입력 글자 수 표시: JS에서 실시간 업데이트 -->
        <p id="inviteCodeCount" class="mt-1 text-right text-xs text-slate-400">0 / 16</p>
        <div class="mt-2">
            <button onclick="submitInviteCode()"
                    class="w-full rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">참여하기</button>
        </div>
    </div>
</div>

<script>const ctx = '${ctx}';</script>
<script src="${ctx}/dist/js/common.js"></script>
<script src="${ctx}/dist/js/plans.js"></script>
</body>
</html>
