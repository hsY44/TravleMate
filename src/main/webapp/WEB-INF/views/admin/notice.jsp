<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<c:set var="activePage" value="notices"/>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 공지사항 관리</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_admin.jsp" %>

    <main class="flex-1 p-6">
        <div class="mx-auto max-w-5xl">

            <!-- 헤더 -->
            <div class="mb-6 flex items-center justify-between">
                <h1 class="text-2xl font-bold text-slate-900">공지사항 관리</h1>
                <button onclick="openWriteModal()"
                        class="flex items-center gap-1.5 rounded-xl bg-sky-500 px-4 py-2 text-sm font-semibold text-white hover:bg-sky-600">
                    <i data-lucide="plus" class="h-4 w-4"></i> 공지 등록
                </button>
            </div>

            <!-- 공지사항 목록 테이블 -->
            <div class="overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
                <table class="w-full text-sm text-slate-700">
                    <thead class="border-b border-slate-100 bg-slate-50 text-xs font-semibold uppercase tracking-wide text-slate-500">
                        <tr>
                            <th class="px-4 py-3 text-left">번호</th>
                            <th class="px-4 py-3 text-left">제목</th>
                            <th class="px-4 py-3 text-left w-24">조회수</th>
                            <th class="px-4 py-3 text-left w-32">등록일</th>
                            <th class="px-4 py-3 text-left w-28">관리</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <c:forEach var="n" items="${notices}">
                            <tr class="hover:bg-slate-50">
                                <td class="px-4 py-3 text-slate-400">${n.noticeNo}</td>
                                <td class="px-4 py-3 font-semibold text-slate-900 max-w-sm">
                                    <span class="line-clamp-1">${n.noticeTitle}</span>
                                </td>
                                <td class="px-4 py-3 text-slate-500">${n.viewCnt}</td>
                                <td class="px-4 py-3 whitespace-nowrap">${n.createDt}</td>
                                <td class="px-4 py-3">
                                    <div class="flex gap-1.5">
                                        <button onclick="openEditModal(${n.noticeNo})"
                                                class="rounded-lg bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-200">
                                            수정
                                        </button>
                                        <button onclick="deleteNotice(${n.noticeNo})"
                                                class="rounded-lg bg-red-50 px-2.5 py-1 text-xs font-semibold text-red-500 hover:bg-red-100">
                                            삭제
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty notices}">
                            <tr>
                                <td colspan="5" class="py-12 text-center text-slate-400">등록된 공지사항이 없습니다.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

            <!-- 페이징 -->
            <c:if test="${pageInfo.totalPages > 0}">
                <div class="mt-5 flex items-center justify-center gap-1">
                    <c:if test="${pageInfo.hasPrev()}">
                        <a href="?page=${pageInfo.blockStart - 1}"
                           class="rounded-lg border border-slate-200 px-3 py-1.5 text-sm text-slate-600 hover:bg-slate-100">&lt;</a>
                    </c:if>
                    <c:forEach begin="${pageInfo.blockStart}" end="${pageInfo.blockEnd}" var="p">
                        <a href="?page=${p}"
                           class="rounded-lg border px-3 py-1.5 text-sm font-semibold
                               ${p == pageInfo.page ? 'border-sky-500 bg-sky-500 text-white' : 'border-slate-200 text-slate-600 hover:bg-slate-100'}">
                            ${p}
                        </a>
                    </c:forEach>
                    <c:if test="${pageInfo.hasNext()}">
                        <a href="?page=${pageInfo.blockEnd + 1}"
                           class="rounded-lg border border-slate-200 px-3 py-1.5 text-sm text-slate-600 hover:bg-slate-100">&gt;</a>
                    </c:if>
                </div>
            </c:if>

        </div>
    </main>
</div>

<!-- 등록/수정 모달 -->
<div id="noticeModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40"
     onclick="closeModal()">
    <div class="w-full max-w-lg rounded-2xl bg-white p-6 shadow-xl" onclick="event.stopPropagation()">
        <div class="mb-4 flex items-center justify-between">
            <h3 id="modalTitle" class="text-lg font-semibold text-slate-900">공지 등록</h3>
            <button onclick="closeModal()" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>

        <input type="hidden" id="editNoticeNo">

        <div class="flex flex-col gap-3">
            <div>
                <label class="mb-1 block text-xs font-semibold text-slate-500">제목</label>
                <input type="text" id="noticeTitle" placeholder="공지 제목을 입력하세요"
                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-sky-400">
            </div>
            <div>
                <label class="mb-1 block text-xs font-semibold text-slate-500">내용</label>
                <textarea id="noticeContent" rows="8" placeholder="공지 내용을 입력하세요"
                          class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-sky-400"></textarea>
            </div>
        </div>

        <p id="noticeModalMsg" class="mt-2 hidden text-xs text-red-400"></p>

        <div class="mt-4 flex justify-end gap-2">
            <button onclick="closeModal()"
                    class="rounded-xl bg-slate-100 px-4 py-2.5 text-sm font-semibold text-slate-600 hover:bg-slate-200">취소</button>
            <button onclick="saveNotice()"
                    class="rounded-xl bg-sky-500 px-4 py-2.5 text-sm font-semibold text-white hover:bg-sky-600">저장</button>
        </div>
    </div>
</div>

<!-- 삭제 확인 모달 -->
<div id="confirmModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40"
     onclick="closeConfirm()">
    <div class="w-full max-w-sm rounded-2xl bg-white p-6 shadow-xl" onclick="event.stopPropagation()">
        <h3 class="mb-3 text-base font-semibold text-slate-900">공지 삭제</h3>
        <p class="mb-5 text-sm text-slate-600">선택한 공지사항을 삭제하시겠습니까?</p>
        <div class="flex justify-end gap-2">
            <button onclick="closeConfirm()"
                    class="rounded-xl bg-slate-100 px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-200">취소</button>
            <button id="confirmOkBtn"
                    class="rounded-xl bg-red-500 px-4 py-2 text-sm font-semibold text-white hover:bg-red-600">삭제</button>
        </div>
    </div>
</div>

<script>const ctx = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/dist/js/common.js"></script>
<script>

	let editMode = false;
	
	function openWriteModal()
	{
	    editMode = false;
	    document.getElementById('modalTitle').textContent   = '공지 등록';
	    document.getElementById('editNoticeNo').value       = '';
	    document.getElementById('noticeTitle').value        = '';
	    document.getElementById('noticeContent').value      = '';
	    document.getElementById('noticeModalMsg').classList.add('hidden');
	    showModal();
	}
	
	function openEditModal(noticeNo)
	{
	    editMode = true;
	    document.getElementById('modalTitle').textContent   = '공지 수정';
	    document.getElementById('editNoticeNo').value       = noticeNo;
	    document.getElementById('noticeTitle').value        = '';
	    document.getElementById('noticeContent').value      = '로딩 중...';
	    document.getElementById('noticeModalMsg').classList.add('hidden');
	    showModal();
	
	    fetch(ctx + '/admin/notice/' + noticeNo)
	        .then(r => r.json())
	        .then(n => {
	            document.getElementById('noticeTitle').value   = n.noticeTitle   ?? '';
	            document.getElementById('noticeContent').value = n.noticeContent ?? '';
	        });
	}
	
	function showModal()
	{
	    const m = document.getElementById('noticeModal');
	    m.classList.remove('hidden');
	    m.classList.add('flex');
	}
	
	function closeModal()
	{
	    const m = document.getElementById('noticeModal');
	    m.classList.add('hidden');
	    m.classList.remove('flex');
	}
	
	function saveNotice()
	{
	    const noticeNo      = document.getElementById('editNoticeNo').value;
	    const noticeTitle   = document.getElementById('noticeTitle').value.trim();
	    const noticeContent = document.getElementById('noticeContent').value.trim();
	    const msg           = document.getElementById('noticeModalMsg');
	
	    if (!noticeTitle || !noticeContent)
	    {
	        msg.textContent = '제목과 내용을 모두 입력하세요.';
	        msg.classList.remove('hidden');
	        return;
	    }
	
	    const url    = editMode ? ctx + '/admin/notice/' + noticeNo : ctx + '/admin/notice';
	    const method = editMode ? 'PUT' : 'POST';
	
	    fetch(url, {
	        method,
	        headers: { 'Content-Type': 'application/json' },
	        body: JSON.stringify({ noticeTitle, noticeContent })
	    })
	    .then(r => r.json())
	    .then(data => {
	        if (data.result === 'ok') { location.reload(); }
	        else
	        {
	            msg.textContent = '저장 실패';
	            msg.classList.remove('hidden');
	        }
	    });
	}
	
	function deleteNotice(noticeNo)
	{
	    const m = document.getElementById('confirmModal');
	    m.classList.remove('hidden');
	    m.classList.add('flex');
	
	    document.getElementById('confirmOkBtn').onclick = function()
	    {
	        fetch(ctx + '/admin/notice/' + noticeNo, { method: 'DELETE' })
	            .then(r => r.json())
	            .then(data => {
	                if (data.result === 'ok') { location.reload(); }
	            });
	    };
	}
	
	function closeConfirm()
	{
	    const m = document.getElementById('confirmModal');
	    m.classList.add('hidden');
	    m.classList.remove('flex');
	}
</script>
</body>
</html>
