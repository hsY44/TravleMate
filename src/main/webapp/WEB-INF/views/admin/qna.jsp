<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<c:set var="ctx"        value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="qnas"/>
<!DOCTYPE html>
<html>
<head>
    <link rel="icon" href="data:;base64,iVBORw0KGgo=">
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 문의 관리</title>
    <link rel="stylesheet" href="${ctx}/dist/css/admin.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_admin.jsp" %>

    <main class="flex-1 p-6">
        <div class="mx-auto max-w-6xl">

            <div class="mb-6">
                <h1 class="text-2xl font-bold text-slate-900">문의 관리</h1>
            </div>

            <!-- 문의 목록 -->
            <div class="overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm" style="min-height:80px">
                <table class="w-full text-sm text-slate-700">
                    <thead class="border-b border-slate-100 bg-slate-50 text-xs font-semibold uppercase tracking-wide text-slate-500">
                        <tr>
                            <th class="px-4 py-3 text-left">번호</th>
                            <th class="px-4 py-3 text-left">카테고리</th>
                            <th class="px-4 py-3 text-left">제목</th>
                            <th class="px-4 py-3 text-left">작성자</th>
                            <th class="px-4 py-3 text-left">상태</th>
                            <th class="px-4 py-3 text-left">등록일</th>
                            <th class="px-4 py-3 text-left">관리</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100">
                        <c:forEach var="q" items="${qnaList}">
                            <tr class="hover:bg-slate-50">
                                <td class="px-4 py-3 text-slate-400">${q.qnaReqNo}</td>
                                <td class="px-4 py-3">
                                    <span class="rounded-full bg-sky-100 px-2 py-0.5 text-xs font-semibold text-sky-600">${q.qnaTypeNm}</span>
                                </td>
                                <td class="max-w-xs px-4 py-3 font-semibold text-slate-900">
                                    <span class="line-clamp-1">${q.qnaTitle}</span>
                                </td>
                                <td class="px-4 py-3">${q.memberNickname}</td>
                                <td class="px-4 py-3">
                                    <span class="rounded-full px-2 py-0.5 text-xs font-semibold
                                        ${q.statusCd eq 'ST002' ? 'bg-emerald-100 text-emerald-600' : 'bg-amber-100 text-amber-600'}">
                                        ${q.statusCd eq 'ST002' ? '답변완료' : '답변대기'}
                                    </span>
                                </td>
                                <td class="whitespace-nowrap px-4 py-3">${q.createDt}</td>
                                <td class="px-4 py-3">
                                    <button onclick="openDrawer(${q.qnaReqNo})"
                                            class="rounded-lg bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-200">
                                        상세보기
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty qnaList}">
                            <tr>
                                <td colspan="7" class="py-12 text-center text-slate-400">문의 내역이 없습니다.</td>
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

<!-- 문의 상세 드로어 -->
<div id="drawerBackdrop" class="drawer-backdrop hidden" onclick="closeDrawer()"></div>
<aside id="drawerPanel" class="drawer-panel closed">
    <div class="flex items-center justify-between border-b border-slate-200 p-4">
        <h3 class="font-semibold text-slate-900">문의 상세</h3>
        <button onclick="closeDrawer()" class="text-slate-400 hover:text-slate-600">
            <i data-lucide="x" class="h-5 w-5"></i>
        </button>
    </div>
    <div id="drawerContent" class="flex flex-1 flex-col gap-4 overflow-auto p-4">
        <p class="text-center text-sm text-slate-400">로딩 중...</p>
    </div>
</aside>

<!-- 답변 모달 -->
<div id="answerModal" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/40"
     onclick="closeAnswerModal()">
    <div class="w-full max-w-lg rounded-2xl bg-white p-6 shadow-xl" onclick="event.stopPropagation()">
        <div class="mb-4 flex items-center justify-between">
            <h3 class="text-lg font-semibold text-slate-900">답변 등록</h3>
            <button onclick="closeAnswerModal()" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>
        <input type="hidden" id="answerQnaReqNo">
        <textarea id="answerContent" rows="6" placeholder="답변 내용을 입력하세요"
                  class="w-full rounded-xl border border-slate-200 px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-sky-400"></textarea>
        <p id="answerMsg" class="mt-2 hidden text-xs text-red-400"></p>
        <div class="mt-4 flex justify-end gap-2">
            <button onclick="closeAnswerModal()"
                    class="rounded-xl bg-slate-100 px-4 py-2.5 text-sm font-semibold text-slate-600 hover:bg-slate-200">취소</button>
            <button onclick="submitAnswer()"
                    class="rounded-xl bg-sky-500 px-4 py-2.5 text-sm font-semibold text-white hover:bg-sky-600">답변 등록</button>
        </div>
    </div>
</div>

<script>const ctx = '${pageContext.request.contextPath}';</script>
<script src="${ctx}/dist/js/common.js"></script>
<script src="${ctx}/dist/js/admin/qna.js"></script>
</body>
</html>
