<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx"        value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="category"/>
<!DOCTYPE html>
<html lang="ko">
<head>
    <link rel="icon" href="data:;base64,iVBORw0KGgo=">
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 카테고리 관리</title>
    <link rel="stylesheet" href="${ctx}/dist/css/admin.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_admin.jsp" %>

    <main class="flex-1 p-6">
        <div class="mx-auto max-w-5xl">

            <h1 class="mb-6 text-2xl font-bold text-slate-900">카테고리 관리</h1>

            <!-- 탭 -->
            <div class="mb-4 flex border-b border-slate-200">
                <button onclick="switchTab('action')"
                        id="tab-action"
                        class="tab-btn border-b-2 border-sky-500 px-4 py-2.5 text-sm font-semibold text-sky-600">
                    편집종류
                </button>
                <button onclick="switchTab('faq')"
                        id="tab-faq"
                        class="tab-btn border-b-2 border-transparent px-4 py-2.5 text-sm font-semibold text-slate-500 hover:text-slate-700">
                    FAQ 카테고리
                </button>
                <button onclick="switchTab('theme')"
                        id="tab-theme"
                        class="tab-btn border-b-2 border-transparent px-4 py-2.5 text-sm font-semibold text-slate-500 hover:text-slate-700">
                    여행 테마
                </button>
            </div>

            <!-- ── 편집종류 탭 ── -->
            <div id="panel-action">
                <div class="mb-4 flex items-center justify-between">
                    <p class="text-sm text-slate-500">일정에서 사용할 편집 행동 종류를 관리합니다.</p>
                    <button onclick="openModal('action', 'add')"
                            class="flex items-center gap-1.5 rounded-xl bg-sky-500 px-4 py-2 text-sm font-semibold text-white hover:bg-sky-600">
                        <i data-lucide="plus" class="h-4 w-4"></i> 추가
                    </button>
                </div>
                <div class="overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
                    <table class="w-full text-sm text-slate-700">
                        <thead class="border-b border-slate-100 bg-slate-50 text-xs font-semibold uppercase tracking-wide text-slate-500">
                            <tr>
                                <th class="px-4 py-3 text-left w-40">코드</th>
                                <th class="px-4 py-3 text-left">편집종류명</th>
                                <th class="px-4 py-3 text-left w-24">관리</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <c:forEach var="t" items="${actionTypes}">
                                <tr class="hover:bg-slate-50">
                                    <td class="px-4 py-3 font-mono text-slate-400">${t.actionTypeCd}</td>
                                    <td class="px-4 py-3 font-semibold text-slate-900">${t.actionTypeNm}</td>
                                    <td class="px-4 py-3">
                                        <button onclick="openModal('action','edit','${t.actionTypeCd}','${t.actionTypeNm}')"
                                                class="rounded-lg bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-200">
                                            수정
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty actionTypes}">
                                <tr><td colspan="3" class="py-12 text-center text-slate-400">등록된 편집종류가 없습니다.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- ── FAQ 카테고리 탭 ── -->
            <div id="panel-faq" class="hidden">
                <div class="mb-4 flex items-center justify-between">
                    <p class="text-sm text-slate-500">자주 묻는 질문의 분류 항목을 관리합니다.</p>
                    <button onclick="openModal('faq', 'add')"
                            class="flex items-center gap-1.5 rounded-xl bg-sky-500 px-4 py-2 text-sm font-semibold text-white hover:bg-sky-600">
                        <i data-lucide="plus" class="h-4 w-4"></i> 추가
                    </button>
                </div>
                <div class="overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
                    <table class="w-full text-sm text-slate-700">
                        <thead class="border-b border-slate-100 bg-slate-50 text-xs font-semibold uppercase tracking-wide text-slate-500">
                            <tr>
                                <th class="px-4 py-3 text-left w-40">코드</th>
                                <th class="px-4 py-3 text-left">카테고리명</th>
                                <th class="px-4 py-3 text-left w-24">관리</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <c:forEach var="t" items="${faqTypes}">
                                <tr class="hover:bg-slate-50">
                                    <td class="px-4 py-3 font-mono text-slate-400">${t.faqTypeCd}</td>
                                    <td class="px-4 py-3 font-semibold text-slate-900">${t.faqTypeNm}</td>
                                    <td class="px-4 py-3">
                                        <button onclick="openModal('faq','edit','${t.faqTypeCd}','${t.faqTypeNm}')"
                                                class="rounded-lg bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-200">
                                            수정
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty faqTypes}">
                                <tr><td colspan="3" class="py-12 text-center text-slate-400">등록된 카테고리가 없습니다.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- ── 여행 테마 탭 ── -->
            <div id="panel-theme" class="hidden">
                <div class="mb-4 flex items-center justify-between">
                    <p class="text-sm text-slate-500">여행 계획에서 선택할 수 있는 테마를 관리합니다. 계획에서 사용 중인 테마는 삭제할 수 없습니다.</p>
                    <button onclick="openModal('theme', 'add')"
                            class="flex items-center gap-1.5 rounded-xl bg-sky-500 px-4 py-2 text-sm font-semibold text-white hover:bg-sky-600">
                        <i data-lucide="plus" class="h-4 w-4"></i> 추가
                    </button>
                </div>
                <div class="overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
                    <table class="w-full text-sm text-slate-700">
                        <thead class="border-b border-slate-100 bg-slate-50 text-xs font-semibold uppercase tracking-wide text-slate-500">
                            <tr>
                                <th class="px-4 py-3 text-left w-40">코드</th>
                                <th class="px-4 py-3 text-left">테마명</th>
                                <th class="px-4 py-3 text-left w-32">사용 중인 계획</th>
                                <th class="px-4 py-3 text-left w-32">관리</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <c:forEach var="t" items="${themes}">
                                <tr class="hover:bg-slate-50">
                                    <td class="px-4 py-3 font-mono text-slate-400">${t.travelThemeCd}</td>
                                    <td class="px-4 py-3 font-semibold text-slate-900">${t.travelThemeNm}</td>
                                    <td class="px-4 py-3">
                                        <c:choose>
                                            <c:when test="${t.planCount > 0}">
                                                <span class="inline-flex items-center gap-1 rounded-full bg-amber-100 px-2.5 py-0.5 text-xs font-semibold text-amber-700">
                                                    <i data-lucide="link" class="h-3 w-3"></i> ${t.planCount}건
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-slate-400 text-xs">—</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="px-4 py-3 flex items-center gap-1.5">
                                        <button onclick="openModal('theme','edit','${t.travelThemeCd}','${t.travelThemeNm}')"
                                                class="rounded-lg bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-200">
                                            수정
                                        </button>
                                        <button onclick="deleteTheme('${t.travelThemeCd}', '${t.travelThemeNm}', ${t.planCount})"
                                                class="rounded-lg px-2.5 py-1 text-xs font-semibold
                                                    ${t.planCount > 0 ? 'cursor-not-allowed bg-slate-50 text-slate-300' : 'bg-red-50 text-red-500 hover:bg-red-100'}">
                                            삭제
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty themes}">
                                <tr><td colspan="4" class="py-12 text-center text-slate-400">등록된 테마가 없습니다.</td></tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </main>
</div>

<!-- 공통 모달 (탭별로 재사용) -->
<div id="categoryModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40"
     onclick="closeModal()">
    <div class="w-full max-w-sm rounded-2xl bg-white p-6 shadow-xl" onclick="event.stopPropagation()">
        <div class="mb-4 flex items-center justify-between">
            <h3 id="modalTitle" class="text-lg font-semibold text-slate-900"></h3>
            <button onclick="closeModal()" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>

        <div class="flex flex-col gap-3">
            <div id="cdField">
                <label class="mb-1 block text-xs font-semibold text-slate-500">코드</label>
                <input type="text" id="inputCd" placeholder="예: ACT004"
                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-sky-400">
            </div>
            <div>
                <label class="mb-1 block text-xs font-semibold text-slate-500">이름</label>
                <input type="text" id="inputNm" placeholder="이름을 입력하세요"
                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-sky-400">
            </div>
        </div>
        <p id="modalMsg" class="mt-2 hidden text-xs text-red-400"></p>
        <div class="mt-4 flex justify-end gap-2">
            <button onclick="closeModal()"
                    class="rounded-xl bg-slate-100 px-4 py-2.5 text-sm font-semibold text-slate-600 hover:bg-slate-200">취소</button>
            <button onclick="saveCategory()"
                    class="rounded-xl bg-sky-500 px-4 py-2.5 text-sm font-semibold text-white hover:bg-sky-600">저장</button>
        </div>
    </div>
</div>

<script>const ctx = '${ctx}';</script>
<script src="${ctx}/dist/js/common.js"></script>
<script>
const ALL_TABS = ['action', 'faq', 'theme'];

let modalType = '';
let modalMode = '';
let modalCd   = '';

/* ── 탭 전환 ── */
function switchTab(name) {
    ALL_TABS.forEach(t => {
        document.getElementById('panel-' + t).classList.add('hidden');
        const btn = document.getElementById('tab-' + t);
        btn.classList.remove('border-sky-500', 'text-sky-600');
        btn.classList.add('border-transparent', 'text-slate-500');
    });
    document.getElementById('panel-' + name).classList.remove('hidden');
    const active = document.getElementById('tab-' + name);
    active.classList.add('border-sky-500', 'text-sky-600');
    active.classList.remove('border-transparent', 'text-slate-500');
}

/* ── 모달 열기 ── */
function openModal(type, mode, cd, nm) {
    modalType = type;
    modalMode = mode;
    modalCd   = cd || '';

    const labels = { action: '편집종류', qna: '문의 카테고리', faq: 'FAQ 카테고리', theme: '여행 테마' };
    const isEdit = mode === 'edit';

    document.getElementById('modalTitle').textContent =
        labels[type] + (isEdit ? ' 수정' : ' 추가');
    document.getElementById('inputCd').value = isEdit ? cd : '';
    document.getElementById('inputNm').value = isEdit ? nm : '';
    document.getElementById('cdField').style.display = isEdit ? 'none' : '';
    document.getElementById('modalMsg').classList.add('hidden');

    const m = document.getElementById('categoryModal');
    m.classList.remove('hidden');
    m.classList.add('flex');
}

function closeModal() {
    const m = document.getElementById('categoryModal');
    m.classList.add('hidden');
    m.classList.remove('flex');
}

/* ── 저장 ── */
async function saveCategory() {
    const cd  = modalMode === 'edit' ? modalCd : document.getElementById('inputCd').value.trim();
    const nm  = document.getElementById('inputNm').value.trim();
    const msg = document.getElementById('modalMsg');

    if (!nm || (modalMode === 'add' && !cd)) {
        msg.textContent = '모든 항목을 입력하세요.';
        msg.classList.remove('hidden');
        return;
    }

    const endpoints = {
        action: { base: ctx + '/admin/itineraryActionType', json: false },
        faq:    { base: ctx + '/admin/faqType',             json: true  },
        theme:  { base: ctx + '/admin/theme',               json: false }
    };
    const { base, json } = endpoints[modalType];
    const url    = modalMode === 'edit' ? base + '/' + cd : base;
    const method = modalMode === 'edit' ? 'PUT' : 'POST';

    try {
        let opts;
        if (json) {
            const key = { faq: 'faqType' }[modalType];
            const body = {};
            body[key + 'Cd'] = cd;
            body[key + 'Nm'] = nm;
            opts = { method, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) };
        } else {
            opts = {
                method,
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'cd=' + encodeURIComponent(cd) + '&nm=' + encodeURIComponent(nm)
            };
        }

        const res = await fetch(url, opts);
        if (!res.ok) throw new Error('HTTP ' + res.status);
        location.reload();
    } catch (e) {
        msg.textContent = e.message || '저장에 실패했습니다.';
        msg.classList.remove('hidden');
    }
}

/* ── 테마 삭제 ── */
async function deleteTheme(cd, nm, planCount) {
    if (planCount > 0) return;
    if (!confirm('"' + nm + '" 테마를 삭제하시겠습니까?')) return;

    try {
        const res = await fetch(ctx + '/admin/theme/' + encodeURIComponent(cd), { method: 'DELETE' });
        if (res.status === 409) {
            showToast('사용 중인 계획이 있어 삭제할 수 없습니다.', 2000, 'error');
            return;
        }
        if (!res.ok) throw new Error('HTTP ' + res.status);
        location.reload();
    } catch (e) {
        showToast(e.message || '삭제에 실패했습니다.', 2000, 'error');
    }
}
</script>
</body>
</html>
