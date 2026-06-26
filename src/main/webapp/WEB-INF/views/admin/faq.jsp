<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>
<c:set var="activePage" value="faqs"/>

<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — FAQ 관리</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/admin.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_admin.jsp" %>

    <main class="flex-1 p-6">
        <div class="mx-auto max-w-4xl">

            <!-- 헤더 -->
            <div class="mb-6 flex items-center justify-between">
                <h1 class="text-2xl font-bold text-slate-900">FAQ 관리</h1>
                <div class="flex gap-2">
                    <a href="${pageContext.request.contextPath}/admin/category"
                       class="rounded-xl border border-slate-200 bg-white px-4 py-2 text-sm font-semibold text-slate-600 hover:bg-slate-50">
                        카테고리 관리
                    </a>
                    
                    <button onclick="openWriteModal()"
                            class="flex items-center gap-1.5 rounded-xl bg-sky-500 px-4 py-2 text-sm font-semibold text-white hover:bg-sky-600">
                        <i data-lucide="plus" class="h-4 w-4"></i> FAQ 등록
                    </button>
                </div>
            </div>

            <!-- FAQ 목록 -->
            <div class="overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
                <table class="w-full text-sm text-slate-700">
                    <thead class="border-b border-slate-100 bg-slate-50 text-xs font-semibold uppercase tracking-wide text-slate-500">
                        <tr>
                            <th class="px-4 py-3 text-left">번호</th>
                            <th class="px-4 py-3 text-left">카테고리</th>
                            <th class="px-4 py-3 text-left">질문</th>
                            <th class="px-4 py-3 text-left">등록일</th>
                            <th class="px-4 py-3 text-left">관리</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <c:forEach var="f" items="${faqs}">
                            <tr class="hover:bg-slate-50">
                                <td class="px-4 py-3 text-slate-400">${f.faqNo}</td>
                                <td class="px-4 py-3">
                                    <span class="rounded-full bg-sky-100 px-2 py-0.5 text-xs font-semibold text-sky-600">${f.faqTypeNm}</span>
                                </td>
                                <td class="px-4 py-3 font-semibold text-slate-900 max-w-sm">
                                    <span class="line-clamp-1">${f.faqQuestion}</span>
                                </td>
                                <td class="px-4 py-3 whitespace-nowrap">${f.createDt}</td>
                                <td class="px-4 py-3">
                                    <div class="flex gap-1.5">
                                        <button onclick="openEditModalFromBtn(this)"
                                                data-faq-no="${f.faqNo}"
                                                data-faq-type="${f.faqTypeCd}"
                                                data-faq-question="${fn:escapeXml(f.faqQuestion)}"
                                                data-faq-answer="${fn:escapeXml(f.faqAnswer)}"
                                                class="rounded-lg bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-200">
                                            수정
                                        </button>
                                        <button onclick="deleteFaq(${f.faqNo})"
                                                class="rounded-lg bg-red-50 px-2.5 py-1 text-xs font-semibold text-red-500 hover:bg-red-100">
                                            삭제
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty faqs}">
                            <tr>
                                <td colspan="5" class="py-12 text-center text-slate-400">등록된 FAQ가 없습니다.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

        </div>
    </main>
</div>

<!-- 등록/수정 모달 -->
<div id="faqModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40"
     onclick="closeModal()">
    <div class="w-full max-w-lg rounded-2xl bg-white p-6 shadow-xl" onclick="event.stopPropagation()">
        <div class="mb-4 flex items-center justify-between">
            <h3 id="modalTitle" class="text-lg font-semibold text-slate-900">FAQ 등록</h3>
            <button onclick="closeModal()" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>

        <input type="hidden" id="editFaqNo">

        <div class="flex flex-col gap-3">
            <div>
                <label class="mb-1 block text-xs font-semibold text-slate-500">카테고리</label>
                <select id="faqTypeCd"
                        class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-sky-400">
                    <c:forEach var="t" items="${faqTypes}">
                        <option value="${t.faqTypeCd}">${t.faqTypeNm}</option>
                    </c:forEach>
                </select>
            </div>
            <div>
                <label class="mb-1 block text-xs font-semibold text-slate-500">질문</label>
                <input type="text" id="faqQuestion" placeholder="질문을 입력하세요"
                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-sky-400">
            </div>
            <div>
                <label class="mb-1 block text-xs font-semibold text-slate-500">답변</label>
                <textarea id="faqAnswer" rows="5" placeholder="답변을 입력하세요"
                          class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-sky-400"></textarea>
            </div>
        </div>

        <p id="faqModalMsg" class="mt-2 hidden text-xs text-red-400"></p>

        <div class="mt-4 flex justify-end gap-2">
            <button onclick="closeModal()"
                    class="rounded-xl bg-slate-100 px-4 py-2.5 text-sm font-semibold text-slate-600 hover:bg-slate-200">취소</button>
            <button onclick="saveFaq()"
                    class="rounded-xl bg-sky-500 px-4 py-2.5 text-sm font-semibold text-white hover:bg-sky-600">저장</button>
        </div>
    </div>
</div>

<!-- 삭제 확인 모달 -->
<div id="confirmModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40"
     onclick="closeConfirm()">
    <div class="w-full max-w-sm rounded-2xl bg-white p-6 shadow-xl" onclick="event.stopPropagation()">
        <h3 class="mb-3 text-base font-semibold text-slate-900">FAQ 삭제</h3>
        <p class="mb-5 text-sm text-slate-600">선택한 FAQ를 삭제하시겠습니까?</p>
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

	function openEditModalFromBtn(btn)
	{
	    openEditModal(
	        btn.dataset.faqNo,
	        btn.dataset.faqType,
	        btn.dataset.faqQuestion,
	        btn.dataset.faqAnswer
	    );
	}

	function openWriteModal()
	{
	    editMode = false;
	    document.getElementById('modalTitle').textContent = 'FAQ 등록';
	    document.getElementById('editFaqNo').value        = '';
	    document.getElementById('faqQuestion').value      = '';
	    document.getElementById('faqAnswer').value        = '';
	    document.getElementById('faqModalMsg').classList.add('hidden');
	    showModal();
	}
	
	function openEditModal(faqNo, typeCd, question, answer)
	{
	    editMode = true;
	    document.getElementById('modalTitle').textContent = 'FAQ 수정';
	    document.getElementById('editFaqNo').value        = faqNo;
	    document.getElementById('faqTypeCd').value        = typeCd;
	    document.getElementById('faqQuestion').value      = question;
	    document.getElementById('faqAnswer').value        = answer;
	    document.getElementById('faqModalMsg').classList.add('hidden');
	    showModal();
	}
	
	function showModal()
	{
	    const m = document.getElementById('faqModal');
	    m.classList.remove('hidden');
	    m.classList.add('flex');
	}
	
	function closeModal()
	{
	    const m = document.getElementById('faqModal');
	    m.classList.add('hidden');
	    m.classList.remove('flex');
	}
	
	function saveFaq()
	{
	    const faqNo      = document.getElementById('editFaqNo').value;
	    const faqTypeCd  = document.getElementById('faqTypeCd').value;
	    const faqQuestion = document.getElementById('faqQuestion').value.trim();
	    const faqAnswer  = document.getElementById('faqAnswer').value.trim();
	    const msg        = document.getElementById('faqModalMsg');
	
	    if (!faqQuestion || !faqAnswer)
	    {
	        msg.textContent = '질문과 답변을 모두 입력하세요.';
	        msg.classList.remove('hidden');
	        return;
	    }
	
	    const url    = editMode ? ctx + '/admin/faq/' + faqNo : ctx + '/admin/faq';
	    const method = editMode ? 'PUT' : 'POST';
	
	    fetch(url, {
	        method,
	        headers: { 'Content-Type': 'application/json' },
	        body: JSON.stringify({ faqTypeCd, faqQuestion, faqAnswer })
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
	
	function deleteFaq(faqNo)
	{
	    const m = document.getElementById('confirmModal');
	    m.classList.remove('hidden');
	    m.classList.add('flex');
	
	    document.getElementById('confirmOkBtn').onclick = function()
	    {
	        fetch(ctx + '/admin/faq/' + faqNo, { method: 'DELETE' })
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
