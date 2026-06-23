<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx"        value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="itineraryActionType"/>
<!DOCTYPE html>
<html lang="ko">
<head>
    <link rel="icon" href="data:;base64,iVBORw0KGgo=">
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 편집종류 관리</title>
    <link rel="stylesheet" href="${ctx}/dist/css/admin.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_admin.jsp" %>

    <main class="flex-1 p-6">
        <div class="mx-auto max-w-2xl">

            <div class="mb-6 flex items-center justify-between">
                <h1 class="text-2xl font-bold text-slate-900">편집종류 관리</h1>
                <button onclick="openAddModal()"
                        class="flex items-center gap-1.5 rounded-xl bg-sky-500 px-4 py-2 text-sm font-semibold text-white hover:bg-sky-600">
                    <i data-lucide="plus" class="h-4 w-4"></i> 추가
                </button>
            </div>

            <div class="overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
                <table class="w-full text-sm text-slate-700">
                    <thead class="border-b border-slate-100 bg-slate-50 text-xs font-semibold uppercase tracking-wide text-slate-500">
                        <tr>
                            <th class="px-4 py-3 text-left">코드</th>
                            <th class="px-4 py-3 text-left">편집종류명</th>
                            <th class="px-4 py-3 text-left">관리</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <c:forEach var="t" items="${actionTypes}">
                            <tr class="hover:bg-slate-50">
                                <td class="px-4 py-3 font-mono text-slate-400">${t.actionTypeCd}</td>
                                <td class="px-4 py-3 font-semibold text-slate-900">${t.actionTypeNm}</td>
                                <td class="px-4 py-3">
                                    <button onclick="openEditModal('${t.actionTypeCd}', '${t.actionTypeNm}')"
                                            class="rounded-lg bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-200">
                                        수정
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty actionTypes}">
                            <tr>
                                <td colspan="3" class="py-12 text-center text-slate-400">등록된 편집종류가 없습니다.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

        </div>
    </main>
</div>

<!-- 추가/수정 모달 -->
<div id="actionTypeModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40"
     onclick="closeTypeModal()">
    <div class="w-full max-w-sm rounded-2xl bg-white p-6 shadow-xl" onclick="event.stopPropagation()">
        <div class="mb-4 flex items-center justify-between">
            <h3 id="modalTitle" class="text-lg font-semibold text-slate-900">편집종류 추가</h3>
            <button onclick="closeTypeModal()" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>

        <input type="hidden" id="editCd">

        <div class="flex flex-col gap-3">
            <div id="cdField">
                <label class="mb-1 block text-xs font-semibold text-slate-500">코드 (영문 대문자)</label>
                <input type="text" id="actionTypeCd" placeholder="예: ACT004"
                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-sky-400">
            </div>
            <div>
                <label class="mb-1 block text-xs font-semibold text-slate-500">편집종류명</label>
                <input type="text" id="actionTypeNm" placeholder="예: 순서변경"
                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-sky-400">
            </div>
        </div>
        <p id="modalMsg" class="mt-2 hidden text-xs text-red-400"></p>
        <div class="mt-4 flex justify-end gap-2">
            <button onclick="closeTypeModal()"
                    class="rounded-xl bg-slate-100 px-4 py-2.5 text-sm font-semibold text-slate-600 hover:bg-slate-200">취소</button>
            <button onclick="saveActionType()"
                    class="rounded-xl bg-sky-500 px-4 py-2.5 text-sm font-semibold text-white hover:bg-sky-600">저장</button>
        </div>
    </div>
</div>

<script>const ctx = '${ctx}';</script>
<script src="${ctx}/dist/js/common.js"></script>
<script>
let editMode = false;

function openAddModal() {
    editMode = false;
    document.getElementById('modalTitle').textContent = '편집종류 추가';
    document.getElementById('editCd').value           = '';
    document.getElementById('actionTypeCd').value     = '';
    document.getElementById('actionTypeNm').value     = '';
    document.getElementById('cdField').style.display  = '';
    document.getElementById('modalMsg').classList.add('hidden');
    showTypeModal();
}

function openEditModal(cd, nm) {
    editMode = true;
    document.getElementById('modalTitle').textContent = '편집종류 수정';
    document.getElementById('editCd').value           = cd;
    document.getElementById('actionTypeNm').value     = nm;
    document.getElementById('cdField').style.display  = 'none';
    document.getElementById('modalMsg').classList.add('hidden');
    showTypeModal();
}

function showTypeModal() {
    const m = document.getElementById('actionTypeModal');
    m.classList.remove('hidden');
    m.classList.add('flex');
}

function closeTypeModal() {
    const m = document.getElementById('actionTypeModal');
    m.classList.add('hidden');
    m.classList.remove('flex');
}

async function saveActionType() {
    const cd  = editMode
        ? document.getElementById('editCd').value
        : document.getElementById('actionTypeCd').value.trim().toUpperCase();
    const nm  = document.getElementById('actionTypeNm').value.trim();
    const msg = document.getElementById('modalMsg');

    if (!nm || (!editMode && !cd)) {
        msg.textContent = '모든 항목을 입력하세요.';
        msg.classList.remove('hidden');
        return;
    }

    const url    = editMode
        ? ctx + '/admin/itineraryActionType/' + cd
        : ctx + '/admin/itineraryActionType';
    const method = editMode ? 'PUT' : 'POST';

    try {
        await fetchJSON(url, {
            method,
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'cd=' + encodeURIComponent(cd) + '&nm=' + encodeURIComponent(nm)
        });
        location.reload();
    } catch (e) {
        msg.textContent = e.message || '저장에 실패했습니다.';
        msg.classList.remove('hidden');
    }
}
</script>
</body>
</html>
