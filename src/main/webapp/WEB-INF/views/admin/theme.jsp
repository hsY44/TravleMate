<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx"        value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="theme"/>
<!DOCTYPE html>
<html lang="ko">
<head>
    <link rel="icon" href="data:;base64,iVBORw0KGgo=">
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 테마 관리</title>
    <link rel="stylesheet" href="${ctx}/dist/css/admin.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_admin.jsp" %>

    <main class="flex-1 p-6">
        <div class="mx-auto max-w-2xl">

            <div class="mb-6 flex items-center justify-between">
                <h1 class="text-2xl font-bold text-slate-900">테마 관리</h1>
                <button onclick="openAddModal()"
                        class="flex items-center gap-1.5 rounded-xl bg-sky-500 px-4 py-2 text-sm font-semibold text-white hover:bg-sky-600">
                    <i data-lucide="plus" class="h-4 w-4"></i> 테마 추가
                </button>
            </div>

            <div class="overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
                <table class="w-full text-sm text-slate-700">
                    <thead class="border-b border-slate-100 bg-slate-50 text-xs font-semibold uppercase tracking-wide text-slate-500">
                        <tr>
                            <th class="px-4 py-3 text-left">코드</th>
                            <th class="px-4 py-3 text-left">테마명</th>
                            <th class="px-4 py-3 text-left w-20">사용 계획</th>
                            <th class="px-4 py-3 text-left w-32">관리</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <c:forEach var="t" items="${themes}">
                            <tr class="hover:bg-slate-50">
                                <td class="px-4 py-3 font-mono text-slate-400">${t.travelThemeCd}</td>
                                <td class="px-4 py-3 font-semibold text-slate-900">${t.travelThemeNm}</td>
                                <td class="px-4 py-3 text-center">
                                    <span class="rounded-full px-2 py-0.5 text-xs font-semibold
                                        ${t.planCount > 0 ? 'bg-sky-100 text-sky-600' : 'bg-slate-100 text-slate-400'}">
                                        ${t.planCount}
                                    </span>
                                </td>
                                <td class="px-4 py-3">
                                    <div class="flex gap-1.5">
                                        <button onclick="openEditModal('${t.travelThemeCd}', '${t.travelThemeNm}')"
                                                class="rounded-lg bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-200">
                                            수정
                                        </button>
                                        <button onclick="deleteTheme('${t.travelThemeCd}', '${t.travelThemeNm}', ${t.planCount})"
                                                class="rounded-lg bg-red-50 px-2.5 py-1 text-xs font-semibold text-red-500 hover:bg-red-100">
                                            삭제
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty themes}">
                            <tr>
                                <td colspan="4" class="py-12 text-center text-slate-400">등록된 테마가 없습니다.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

            <p class="mt-3 text-xs text-slate-400">
                <i data-lucide="info" class="inline h-3.5 w-3.5"></i>
                사용 중인 계획이 있는 테마는 삭제할 수 없습니다.
            </p>

        </div>
    </main>
</div>

<!-- 추가/수정 모달 -->
<div id="themeModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40"
     onclick="closeModal()">
    <div class="w-full max-w-sm rounded-2xl bg-white p-6 shadow-xl" onclick="event.stopPropagation()">
        <div class="mb-4 flex items-center justify-between">
            <h3 id="modalTitle" class="text-lg font-semibold text-slate-900">테마 추가</h3>
            <button onclick="closeModal()" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>

        <input type="hidden" id="editCd">

        <div class="flex flex-col gap-3">
            <div id="cdField">
                <label class="mb-1 block text-xs font-semibold text-slate-500">코드 (영문 대문자)</label>
                <input type="text" id="themeCd" placeholder="예: TH009"
                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-sky-400">
            </div>
            <div>
                <label class="mb-1 block text-xs font-semibold text-slate-500">테마명</label>
                <input type="text" id="themeNm" placeholder="예: 겨울여행"
                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-sky-400">
            </div>
        </div>
        <p id="modalMsg" class="mt-2 hidden text-xs text-red-400"></p>
        <div class="mt-4 flex justify-end gap-2">
            <button onclick="closeModal()"
                    class="rounded-xl bg-slate-100 px-4 py-2.5 text-sm font-semibold text-slate-600 hover:bg-slate-200">취소</button>
            <button onclick="saveTheme()"
                    class="rounded-xl bg-sky-500 px-4 py-2.5 text-sm font-semibold text-white hover:bg-sky-600">저장</button>
        </div>
    </div>
</div>

<!-- 삭제 확인 모달 -->
<div id="confirmModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40"
     onclick="closeConfirm()">
    <div class="w-full max-w-sm rounded-2xl bg-white p-6 shadow-xl" onclick="event.stopPropagation()">
        <h3 class="mb-3 text-base font-semibold text-slate-900">테마 삭제</h3>
        <p id="confirmMsg" class="mb-5 text-sm text-slate-600"></p>
        <div class="flex justify-end gap-2">
            <button onclick="closeConfirm()"
                    class="rounded-xl bg-slate-100 px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-200">취소</button>
            <button id="confirmOkBtn"
                    class="rounded-xl bg-red-500 px-4 py-2 text-sm font-semibold text-white hover:bg-red-600">삭제</button>
        </div>
    </div>
</div>

<script>const ctx = '${ctx}';</script>
<script src="${ctx}/dist/js/common.js"></script>
<script>
let editMode = false;

function openAddModal() {
    editMode = false;
    document.getElementById('modalTitle').textContent = '테마 추가';
    document.getElementById('editCd').value           = '';
    document.getElementById('themeCd').value          = '';
    document.getElementById('themeNm').value          = '';
    document.getElementById('cdField').style.display  = '';
    document.getElementById('modalMsg').classList.add('hidden');
    showThemeModal();
}

function openEditModal(cd, nm) {
    editMode = true;
    document.getElementById('modalTitle').textContent = '테마 수정';
    document.getElementById('editCd').value           = cd;
    document.getElementById('themeNm').value          = nm;
    document.getElementById('cdField').style.display  = 'none';
    document.getElementById('modalMsg').classList.add('hidden');
    showThemeModal();
}

function showThemeModal() {
    const m = document.getElementById('themeModal');
    m.classList.remove('hidden');
    m.classList.add('flex');
}

function closeModal() {
    const m = document.getElementById('themeModal');
    m.classList.add('hidden');
    m.classList.remove('flex');
}

async function saveTheme() {
    const cd  = editMode
        ? document.getElementById('editCd').value
        : document.getElementById('themeCd').value.trim().toUpperCase();
    const nm  = document.getElementById('themeNm').value.trim();
    const msg = document.getElementById('modalMsg');

    if (!nm || (!editMode && !cd)) {
        msg.textContent = '모든 항목을 입력하세요.';
        msg.classList.remove('hidden');
        return;
    }

    const url    = editMode ? ctx + '/admin/theme/' + cd : ctx + '/admin/theme';
    const method = editMode ? 'PUT' : 'POST';

    try {
        const res = await fetch(url, {
            method,
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'cd=' + encodeURIComponent(cd) + '&nm=' + encodeURIComponent(nm)
        });
        if (!res.ok) throw new Error('HTTP ' + res.status);
        location.reload();
    } catch (e) {
        msg.textContent = e.message || '저장에 실패했습니다.';
        msg.classList.remove('hidden');
    }
}

function deleteTheme(cd, nm, planCount) {
    if (planCount > 0) {
        showToast('"' + nm + '" 테마는 ' + planCount + '개의 여행계획에서 사용 중이므로 삭제할 수 없습니다.', 3000, 'error');
        return;
    }
    document.getElementById('confirmMsg').textContent = '"' + nm + '" 테마를 삭제하시겠습니까?';
    const m = document.getElementById('confirmModal');
    m.classList.remove('hidden');
    m.classList.add('flex');

    document.getElementById('confirmOkBtn').onclick = async function() {
        try {
            const res = await fetch(ctx + '/admin/theme/' + cd, { method: 'DELETE' });
            const data = await res.json();
            if (data.result === 'inuse') {
                closeConfirm();
                showToast('사용 중인 계획이 있어 삭제할 수 없습니다.', 2000, 'error');
                return;
            }
            location.reload();
        } catch (e) {
            showToast('삭제에 실패했습니다.', 2000, 'error');
        }
    };
}

function closeConfirm() {
    const m = document.getElementById('confirmModal');
    m.classList.add('hidden');
    m.classList.remove('flex');
}
</script>
</body>
</html>
