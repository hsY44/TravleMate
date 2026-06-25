<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>

<c:set var="ctx"        value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="plans"/>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — ${plan.title}</title>
    <link rel="stylesheet" href="${ctx}/dist/css/user.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_user.jsp" %>

    <main class="mx-auto w-full max-w-6xl flex-1 p-6">

        <!-- 상단 헤더 -->
        <div class="mb-5 flex items-start justify-between gap-4">
            <div class="flex items-center gap-3">
                <a href="${ctx}/plans" class="text-slate-400 hover:text-slate-600">
                    <i data-lucide="arrow-left" class="h-5 w-5"></i>
                </a>
                <div>
                    <div class="flex items-center gap-2">
                        <h1 class="text-xl font-bold text-slate-900">${plan.title}</h1>
                        <span class="rounded-full bg-sky-100 px-2 py-0.5 text-xs font-semibold text-sky-600">${plan.theme}</span>
                    </div>
                    <p class="mt-0.5 flex items-center gap-1.5 text-sm text-slate-400">
                        <i data-lucide="calendar-days" class="h-4 w-4"></i>
                        ${plan.startDate} ~ ${plan.endDate}
                    </p>
                </div>
            </div>
            <div class="flex items-center gap-2">
                <button onclick="copyInviteCode()"
                        class="flex items-center gap-1.5 rounded-xl bg-slate-100 px-3 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-200 transition">
                    <i data-lucide="share-2" class="h-4 w-4"></i> 초대 코드
                </button>
                <c:if test="${not isHost}">
                    <button onclick="leavePlan()"
                            class="flex items-center gap-1.5 rounded-xl bg-red-50 px-3 py-2 text-sm font-semibold text-red-500 hover:bg-red-100 transition">
                        <i data-lucide="log-out" class="h-4 w-4"></i> 나가기
                    </button>
                </c:if>
                <c:if test="${isHost}">
                    <button onclick="openModal('planSettingsModal')"
                            class="rounded-xl bg-slate-100 p-2 text-slate-400 hover:bg-slate-200 transition">
                        <i data-lucide="settings" class="h-5 w-5"></i>
                    </button>
                </c:if>
            </div>
        </div>

        <!-- 탭 -->
        <div class="mb-5 flex gap-1 border-b border-slate-200">
            <button id="tabBtn-schedule" class="tab-btn active px-4" onclick="switchDetailTab('schedule')">일정</button>
            <button id="tabBtn-cost"     class="tab-btn px-4"        onclick="switchDetailTab('cost')">비용</button>
            <button id="tabBtn-guests"   class="tab-btn px-4"        onclick="switchDetailTab('guests')">게스트</button>
            <button id="tabBtn-history"  class="tab-btn px-4"        onclick="switchDetailTab('history')">이력</button>
        </div>

        <!-- 일정 탭 -->
        <div id="tabSchedule">
            <div class="mb-3 flex items-center justify-between">
                <p class="text-sm text-slate-400">총 ${plan.dayCount}일 일정</p>
                <c:if test="${canEdit}">
                    <button onclick="openModal('addScheduleModal')"
                            class="flex items-center gap-1.5 rounded-xl bg-sky-500 px-3 py-2 text-sm font-semibold text-white transition hover:bg-sky-600">
                        <i data-lucide="plus" class="h-4 w-4"></i> 일정 추가
                    </button>
                </c:if>
            </div>
            <div class="flex gap-4 overflow-x-auto pb-4">
                <c:forEach var="dayEntry" items="${schedulesMap}">
                    <div class="min-w-[260px] flex-shrink-0">
                        <div class="mb-3 flex items-center gap-2">
                            <span class="flex h-7 w-7 items-center justify-center rounded-full bg-sky-500 text-xs font-bold text-white">
                                ${dayEntry.key + 1}
                            </span>
                            <span class="text-sm font-semibold text-slate-700">${dayEntry.value[0].dayLabel}</span>
                        </div>
                        <div class="flex flex-col gap-2" id="dayCol${dayEntry.key}" data-day="${dayEntry.key}">
                            <c:forEach var="sc" items="${dayEntry.value}">
                                <div class="schedule-card" data-id="${sc.id}">
                                    <div class="mb-1.5 flex items-center justify-between">
                                        <span class="text-xs font-semibold text-sky-500">${sc.time}</span>
                                        <c:if test="${canEdit}">
                                            <div class="flex gap-1">
                                                <button onclick="openEditSchedule(${sc.id})"
                                                        class="rounded p-1 text-slate-400 hover:bg-slate-100 hover:text-slate-600">
                                                    <i data-lucide="pencil" class="h-3.5 w-3.5"></i>
                                                </button>
                                                <button onclick="deleteSchedule(${sc.id})"
                                                        class="rounded p-1 text-slate-400 hover:bg-red-50 hover:text-red-500">
                                                    <i data-lucide="trash-2" class="h-3.5 w-3.5"></i>
                                                </button>
                                            </div>
                                        </c:if>
                                    </div>
                                    <c:if test="${not empty sc.contentImage}">
                                        <img src="${sc.contentImage}" alt="${sc.contentName}"
                                             class="mb-2 h-28 w-full rounded-lg object-cover bg-slate-100">
                                    </c:if>
                                    <p class="font-semibold text-slate-900 text-sm">${sc.title}</p>
                                    <c:if test="${not empty sc.contentName}">
                                        <p class="mt-0.5 flex items-center gap-1 text-xs text-slate-400">
                                            <i data-lucide="map-pin" class="h-3 w-3"></i> ${sc.contentName}
                                        </p>
                                    </c:if>
                                    <c:if test="${not empty sc.content}">
                                        <p class="mt-1.5 text-xs text-slate-500 line-clamp-2">${sc.content}</p>
                                    </c:if>
                                    <c:if test="${sc.cost > 0}">
                                        <div class="mt-2 flex items-center gap-1 text-xs">
                                            <i data-lucide="wallet" class="h-3.5 w-3.5 text-slate-400"></i>
                                            <span class="font-semibold text-slate-700">
                                                <fmt:formatNumber value="${sc.cost}" pattern="#,###"/>원
                                            </span>
                                            <span class="text-slate-400">${sc.costCategory}</span>
                                        </div>
                                    </c:if>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>

        <!-- 비용 탭 -->
        <div id="tabCost" class="hidden">
            <div class="grid grid-cols-1 gap-6 md:grid-cols-2">
                <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
                    <h3 class="mb-4 font-semibold text-slate-900">카테고리별 지출</h3>
                    <div class="cost-chart-wrap">
                        <canvas id="costChart"></canvas>
                    </div>
                </div>
                <div class="rounded-2xl border border-slate-200 bg-white p-5 shadow-sm">
                    <h3 class="mb-4 font-semibold text-slate-900">지출 내역</h3>
                    <table class="w-full text-sm">
                        <thead>
                            <tr class="border-b border-slate-100">
                                <th class="pb-2 text-left font-semibold text-slate-400">카테고리</th>
                                <th class="pb-2 text-right font-semibold text-slate-400">금액</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="cost" items="${costSummary}">
                                <tr class="border-b border-slate-50">
                                    <td class="py-2 text-slate-600">${cost.category}</td>
                                    <td class="py-2 text-right font-semibold text-slate-900">
                                        <fmt:formatNumber value="${cost.total}" pattern="#,###"/>원
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                        <tfoot>
                            <tr>
                                <td class="pt-3 font-bold text-slate-900">합계</td>
                                <td class="pt-3 text-right font-bold text-sky-500">
                                    <fmt:formatNumber value="${totalCost}" pattern="#,###"/>원
                                </td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </div>
        </div>

        <!-- 게스트 탭 -->
        <div id="tabGuests" class="hidden">
            <c:if test="${isHost}">
                <div class="mb-4 flex items-center justify-between rounded-2xl border border-slate-200 bg-white p-4 shadow-sm">
                    <div>
                        <p class="text-xs text-slate-400 mb-0.5">초대 코드</p>
                        <span id="inviteCodeDisplay" class="font-mono text-lg font-bold text-slate-900 tracking-widest">${plan.inviteCode}</span>
                    </div>
                    <div class="flex gap-2">
                        <button onclick="regenerateInviteCode()"
                                class="flex items-center gap-1 rounded-xl bg-amber-50 px-3 py-2 text-sm font-semibold text-amber-600 hover:bg-amber-100 transition">
                            <i data-lucide="refresh-cw" class="h-3.5 w-3.5"></i> 재생성
                        </button>
                        <button onclick="copyInviteCode()"
                                class="flex items-center gap-1.5 rounded-xl bg-slate-100 px-3 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-200 transition">
                            <i data-lucide="copy" class="h-4 w-4"></i> 복사
                        </button>
                    </div>
                </div>
            </c:if>
            <div class="mb-3 flex items-center gap-1 text-sm text-slate-500">
                멤버 <span class="font-bold text-sky-500">${fn:length(guests)}</span> / 8명
            </div>
            <div class="rounded-2xl border border-slate-200 bg-white shadow-sm overflow-hidden">
                <c:forEach var="g" items="${guests}">
                    <div class="flex items-center justify-between px-4 py-3 border-b border-slate-100 last:border-0">
                        <div class="flex items-center gap-3">
                            <div class="flex h-9 w-9 items-center justify-center rounded-full bg-sky-100 text-sm font-bold text-sky-600">
                                ${g.nickname.charAt(0)}
                            </div>
                            <div>
                                <div class="flex items-center gap-1.5 text-sm font-semibold text-slate-900">
                                    ${g.nickname}
                                    <c:if test="${g.host}">
                                        <i data-lucide="crown" class="h-3.5 w-3.5 text-amber-400"></i>
                                    </c:if>
                                </div>
                                <p class="text-xs text-slate-400">${g.canEdit ? '편집 가능' : '읽기 전용'}</p>
                            </div>
                        </div>
                        <c:if test="${isHost and not g.host}">
                            <div class="flex items-center gap-3">
                                <button onclick="togglePermission(${g.memberId}, ${g.canEdit})"
                                        class="rounded-lg border px-2 py-1 text-xs font-semibold transition ${g.canEdit ? 'border-sky-200 text-sky-500 hover:bg-sky-50' : 'border-slate-200 text-slate-400 hover:bg-slate-50'}">
                                    ${g.canEdit ? '편집 가능' : '읽기 전용'}
                                </button>
                                <button onclick="kickGuest(${g.memberId}, '${g.nickname}')"
                                        class="text-xs text-red-400 hover:text-red-600 font-semibold">내보내기</button>
                            </div>
                        </c:if>
                    </div>
                </c:forEach>
            </div>
        </div>

        <!-- 이력 탭 -->
        <div id="tabHistory" class="hidden">
            <div class="rounded-2xl border border-slate-200 bg-white shadow-sm overflow-hidden">
                <c:choose>
                    <c:when test="${not empty history}">
                        <c:forEach var="h" items="${history}">
                            <div class="flex items-center gap-3 px-4 py-3 border-b border-slate-100 last:border-0 text-sm">
                                <c:set var="histBadgeClass">
                                    <c:choose>
                                        <c:when test="${h.type eq '생성'}">bg-emerald-100 text-emerald-600</c:when>
                                        <c:when test="${h.type eq '수정'}">bg-sky-100 text-sky-600</c:when>
                                        <c:otherwise>bg-red-100 text-red-500</c:otherwise>
                                    </c:choose>
                                </c:set>
                                <span class="shrink-0 rounded-full px-2 py-0.5 text-xs font-semibold ${histBadgeClass}">
                                    ${h.type}
                                </span>
                                <span class="font-semibold text-slate-900">${h.target}</span>
                                <span class="text-slate-400">· ${h.editor}</span>
                                <span class="ml-auto text-xs text-slate-400">${h.editedAt}</span>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <p class="py-10 text-center text-sm text-slate-400">편집 이력이 없습니다.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </main>
</div>

<!-- 일정 추가/수정 모달 -->
<div id="addScheduleModal" class="modal-backdrop hidden" onclick="closeModal('addScheduleModal')">
    <div class="modal-box" onclick="event.stopPropagation()">
        <div class="mb-5 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-slate-900" id="scheduleModalTitle">일정 추가</h2>
            <button onclick="closeModal('addScheduleModal')" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>
        <input type="hidden" id="editScheduleId">
        <div class="flex flex-col gap-3">
            <div class="flex gap-2">
                <div class="flex-1">
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">날짜</label>
                    <select id="schedDay"
                            class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                        <c:forEach var="d" items="${dayLabels}" varStatus="s">
                            <option value="${s.index}">${d}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="flex-1">
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">
                        시간 <span class="text-xs font-normal text-slate-400">(선택)</span>
                    </label>
                    <input type="time" id="schedTime"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                </div>
            </div>
            <div>
                <label class="mb-1.5 block text-sm font-semibold text-slate-900">
                    제목 <span class="text-xs font-normal text-red-400">*</span>
                </label>
                <input type="text" id="schedTitle" placeholder="일정 제목을 입력하세요"
                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
            </div>
            <div>
                <label class="mb-1.5 block text-sm font-semibold text-slate-900">
                    메모 <span class="text-xs font-normal text-slate-400">(선택)</span>
                </label>
                <textarea id="schedContent" rows="2" placeholder="메모를 입력하세요"
                          class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400"></textarea>
            </div>
            <div>
                <label class="mb-1.5 block text-sm font-semibold text-slate-900">
                    장소/컨텐츠 <span class="text-xs font-normal text-slate-400">(선택)</span>
                </label>
                <input type="hidden" id="schedContentNo">
                <input type="hidden" id="schedContentImage">
                <input type="hidden" id="schedMapX">
                <input type="hidden" id="schedMapY">
                <div class="mb-2 flex gap-2">
                    <select id="schedContentCategory" onchange="triggerContentSearch()"
                            class="rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-sky-400 text-sm">
                        <option value="all" data-source="tourapi">전체 — 관광공사</option>
                        <optgroup label="관광/문화 — 한국관광공사">
                            <c:forEach var="cat" items="${cateList}">
                                <c:if test="${cat.contentTypeId eq '12' or cat.contentTypeId eq '14' or cat.contentTypeId eq '15' or cat.contentTypeId eq '25' or cat.contentTypeId eq '28'}">
                                    <option value="${cat.contentTypeId}" data-source="tourapi">${cat.contentDiv}</option>
                                </c:if>
                            </c:forEach>
                        </optgroup>
                        <optgroup label="맛집/숙박/쇼핑 — Kakao">
                            <option value="FD6" data-source="kakao" data-cgc="FD6">음식점</option>
                            <option value="CE7" data-source="kakao" data-cgc="CE7">카페</option>
                            <option value="AD5" data-source="kakao" data-cgc="AD5">숙박</option>
                            <option value="MT1" data-source="kakao" data-cgc="MT1">쇼핑</option>
                        </optgroup>
                    </select>
                    <input type="text" id="schedContentAddr" placeholder="지역 (예: 서울)" autocomplete="off"
                           oninput="triggerContentSearch()"
                           class="flex-1 rounded-xl border border-slate-200 px-3 py-2 focus:outline-none focus:ring-2 focus:ring-sky-400 text-sm">
                </div>
                <div class="relative">
                    <input type="text" id="schedContentSearch" placeholder="장소명으로 검색하세요" autocomplete="off"
                           oninput="triggerContentSearch()"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                    <div id="contentSearchResults"
                         class="absolute z-10 mt-1 w-full rounded-xl border border-slate-200 bg-white shadow-lg hidden max-h-48 overflow-y-auto"></div>
                </div>
                <div id="schedContentPreview" class="mt-2 hidden items-center gap-3 rounded-xl border border-slate-100 bg-slate-50 p-2">
                    <img id="schedContentPreviewImg" src="" alt=""
                         class="h-14 w-14 flex-shrink-0 rounded-lg object-cover bg-slate-200">
                    <div class="min-w-0 flex-1">
                        <p class="flex items-center gap-1 text-xs font-semibold text-slate-800 truncate">
                            <i data-lucide="map-pin" class="h-3 w-3 flex-shrink-0 text-sky-500"></i>
                            <span id="schedContentSelectedName" class="truncate"></span>
                        </p>
                    </div>
                    <button type="button" onclick="clearContentSelection()" class="flex-shrink-0 text-slate-400 hover:text-red-500">
                        <i data-lucide="x" class="h-4 w-4"></i>
                    </button>
                </div>
            </div>
            <div class="flex gap-2">
                <div class="flex-1">
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">
                        비용 <span class="text-xs font-normal text-slate-400">(선택, 원)</span>
                    </label>
                    <input type="number" id="schedCost" placeholder="0" min="0"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                </div>
                <div class="flex-1">
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">비용 카테고리</label>
                    <!-- expenseTypes: Controller에서 DB 조회해서 model에 담아야 함 -->
                    <select id="schedCostCat"
                            class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                        <c:forEach var="et" items="${expenseTypes}">
                            <option value="${et}">${et}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            <div class="mt-2 flex justify-end gap-2">
                <button onclick="closeModal('addScheduleModal')"
                        class="rounded-xl bg-slate-100 px-4 py-2.5 font-semibold text-slate-600 transition hover:bg-slate-200">취소</button>
                <button onclick="saveSchedule()"
                        class="rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">저장</button>
            </div>
        </div>
    </div>
</div>

<!-- 계획 설정 모달 -->
<c:if test="${isHost}">
<div id="planSettingsModal" class="modal-backdrop hidden" onclick="closeModal('planSettingsModal')">
    <div class="modal-box" onclick="event.stopPropagation()">
        <div class="mb-5 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-slate-900">계획 설정</h2>
            <button onclick="closeModal('planSettingsModal')" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>
        <div class="flex flex-col gap-2">
            <button onclick="openModal('editPlanModal'); closeModal('planSettingsModal');"
                    class="w-full rounded-xl border border-slate-200 py-2.5 text-sm font-semibold text-slate-700 hover:bg-slate-50">
                계획 수정
            </button>
            <button onclick="openModal('transferHostModal'); closeModal('planSettingsModal');"
                    class="w-full rounded-xl border border-amber-100 py-2.5 text-sm font-semibold text-amber-600 hover:bg-amber-50">
                호스트 위임
            </button>
            <button onclick="deletePlan()"
                    class="w-full rounded-xl border border-red-100 py-2.5 text-sm font-semibold text-red-500 hover:bg-red-50">
                계획 삭제
            </button>
        </div>
    </div>
</div>

<!-- 계획 수정 모달 -->
<div id="editPlanModal" class="modal-backdrop hidden" onclick="closeModal('editPlanModal')">
    <div class="modal-box" onclick="event.stopPropagation()">
        <div class="mb-5 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-slate-900">계획 수정</h2>
            <button onclick="closeModal('editPlanModal')" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>
        <div class="flex flex-col gap-3">
            <div>
                <label class="mb-1.5 block text-sm font-semibold text-slate-900">여행 제목</label>
                <input type="text" id="editPlanTitle" value="${plan.title}"
                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
            </div>
            <div>
                <label class="mb-1.5 block text-sm font-semibold text-slate-900">테마</label>
                <select id="editPlanTheme"
                        class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                    <c:forEach var="t" items="${themes}">
                        <option value="${t}" ${plan.theme eq t ? 'selected' : ''}>${t}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="flex gap-2">
                <div class="flex-1">
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">시작일</label>
                    <input type="date" id="editPlanStart" value="${plan.startDate}"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                </div>
                <div class="flex-1">
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">종료일</label>
                    <input type="date" id="editPlanEnd" value="${plan.endDate}"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                </div>
            </div>
            <div>
                <label class="mb-1.5 block text-sm font-semibold text-slate-900">개요</label>
                <textarea id="editPlanOverview" rows="3"
                          class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">${plan.overview}</textarea>
            </div>
            <div class="mt-2 flex justify-end gap-2">
                <button onclick="closeModal('editPlanModal')"
                        class="rounded-xl bg-slate-100 px-4 py-2.5 font-semibold text-slate-600 transition hover:bg-slate-200">취소</button>
                <button onclick="savePlanEdit()"
                        class="rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">저장</button>
            </div>
        </div>
    </div>
</div>
</c:if>

<!-- 호스트 위임 모달 -->
<c:if test="${isHost}">
<div id="transferHostModal" class="modal-backdrop hidden" onclick="closeModal('transferHostModal')">
    <div class="modal-box" onclick="event.stopPropagation()">
        <div class="mb-5 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-slate-900">호스트 위임</h2>
            <button onclick="closeModal('transferHostModal')" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>
        <p class="mb-4 text-sm text-slate-500">호스트 역할을 위임할 게스트를 선택하세요.<br>위임 후 현재 당신은 일반 게스트가 됩니다.</p>
        <c:choose>
            <c:when test="${not empty guests}">
                <div class="flex flex-col gap-2 max-h-64 overflow-y-auto">
                    <c:forEach var="g" items="${guests}">
                        <c:if test="${not g.host}">
                            <button onclick="transferHost(${g.memberId}, '${g.nickname}')"
                                    class="flex items-center justify-between rounded-xl border border-slate-200 px-4 py-3 text-left hover:bg-slate-50 transition">
                                <div class="flex items-center gap-3">
                                    <div class="flex h-8 w-8 items-center justify-center rounded-full bg-sky-100 text-sm font-bold text-sky-600">
                                        ${g.nickname.charAt(0)}
                                    </div>
                                    <span class="text-sm font-semibold text-slate-900">${g.nickname}</span>
                                </div>
                                <i data-lucide="crown" class="h-4 w-4 text-amber-400"></i>
                            </button>
                        </c:if>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <p class="py-6 text-center text-sm text-slate-400">위임할 게스트가 없습니다.</p>
            </c:otherwise>
        </c:choose>
    </div>
</div>
</c:if>

<!-- 확인 모달 (공용) -->
<div id="confirmModal" class="modal-backdrop hidden" onclick="closeModal('confirmModal')">
    <div class="modal-box" onclick="event.stopPropagation()">
        <div class="mb-5 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-slate-900">확인</h2>
            <button onclick="closeModal('confirmModal')" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>
        <p id="confirmMessage" class="text-sm text-slate-600"></p>
        <div class="mt-5 flex justify-end gap-2">
            <button onclick="closeModal('confirmModal')"
                    class="rounded-xl bg-slate-100 px-4 py-2.5 font-semibold text-slate-600 transition hover:bg-slate-200">취소</button>
            <button id="confirmOkBtn"
                    class="rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">확인</button>
        </div>
    </div>
</div>

<script>
const ctx           = '${ctx}';
const planId        = ${plan.id};
const isHost        = ${isHost};
const canEdit       = ${canEdit};
const memberNo      = ${memberNo};
const inviteCode    = '${plan.inviteCode}';
const planStartDate = '${plan.startDate}';
const costLabels = [<c:forEach var="cost" items="${costSummary}" varStatus="s">'${cost.category}'<c:if test="${!s.last}">,</c:if></c:forEach>];
const costData   = [<c:forEach var="cost" items="${costSummary}" varStatus="s">${cost.total}<c:if test="${!s.last}">,</c:if></c:forEach>];
</script>
<script src="${ctx}/dist/js/common.js"></script>
<script src="${ctx}/dist/js/planDetail.js"></script>
</body>
</html>
