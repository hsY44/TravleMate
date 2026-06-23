<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="ctx"        value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="${currentTab eq 'faq' ? 'faqs' : 'notices'}"/>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — ${currentTab eq 'faq' ? 'FAQ' : '공지사항'}</title>
    <link rel="stylesheet" href="${ctx}/css/admin.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_admin.jsp" %>

    <main class="flex-1 p-6">
        <div class="mx-auto max-w-5xl">

            <!-- 탭: 공지사항 / FAQ 전환 -->
            <div class="mb-6 flex gap-1 border-b border-slate-200">
                <a href="${ctx}/admin/notices"
                   class="tab-btn px-4 ${currentTab ne 'faq' ? 'active' : ''}">공지사항</a>
                <a href="${ctx}/admin/faqs"
                   class="tab-btn px-4 ${currentTab eq 'faq' ? 'active' : ''}">FAQ</a>
            </div>

            <!-- 헤더 -->
            <div class="mb-4 flex items-center justify-between">
                <h1 class="text-2xl font-bold text-slate-900">
                    <c:choose>
                        <c:when test="${currentTab eq 'faq'}">FAQ</c:when>
                        <c:otherwise>공지사항</c:otherwise>
                    </c:choose>
                </h1>
                <button onclick="openWriteModal()"
                        class="flex items-center gap-1.5 rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">
                    <i data-lucide="plus" class="h-4 w-4"></i> 등록
                </button>
            </div>

            <!-- 목록 테이블 -->
            <div class="overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>번호</th>
                            <!-- FAQ일 때만 카테고리 컬럼 표시 -->
                            <c:if test="${currentTab eq 'faq'}">
                                <th>카테고리</th>
                            </c:if>
                            <th>제목</th>
                            <th>작성자</th>
                            <th>등록일</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="item" items="${items}">
                            <tr>
                                <td class="text-slate-400">${item.no}</td>
                                <c:if test="${currentTab eq 'faq'}">
                                    <td class="whitespace-nowrap">
                                        <span class="rounded-full bg-sky-100 px-2 py-0.5 text-xs font-semibold text-sky-600">${item.category}</span>
                                    </td>
                                </c:if>
                                <td class="max-w-sm">
                                    <span class="line-clamp-1 font-semibold text-slate-900">${item.title}</span>
                                </td>
                                <td class="whitespace-nowrap">${item.adminName}</td>
                                <td class="whitespace-nowrap">
                                    <fmt:formatDate value="${item.createdAt}" pattern="yyyy-MM-dd"/>
                                </td>
                                <td class="whitespace-nowrap">
                                    <div class="flex gap-1.5">
                                        <button onclick="openEditModal(${item.id})"
                                                class="rounded-lg bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-200">수정</button>
                                        <button onclick="deleteItem(${item.id}, '${item.title}')"
                                                class="rounded-lg bg-red-50 px-2.5 py-1 text-xs font-semibold text-red-500 hover:bg-red-100">삭제</button>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                        <!-- 목록 없음 -->
                        <c:if test="${empty items}">
                            <tr>
                                <td colspan="${currentTab eq 'faq' ? '6' : '5'}" class="py-10 text-center text-slate-400">
                                    등록된
                                    <c:choose>
                                        <c:when test="${currentTab eq 'faq'}">FAQ</c:when>
                                        <c:otherwise>공지사항</c:otherwise>
                                    </c:choose>
                                    이 없습니다.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<!-- 등록/수정 모달 -->
<div id="writeModal" class="modal-backdrop hidden" onclick="closeModal('writeModal')">
    <div class="modal-box" onclick="event.stopPropagation()">
        <div class="mb-5 flex items-center justify-between">
            <h2 id="writeModalTitle" class="text-lg font-semibold text-slate-900">등록</h2>
            <button onclick="closeModal('writeModal')" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>
        <input type="hidden" id="editItemId">
        <div class="flex flex-col gap-3">
            <!-- FAQ일 때만 카테고리 선택 표시 -->
            <c:if test="${currentTab eq 'faq'}">
                <div>
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">카테고리</label>
                    <select id="itemCategory"
                            class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                        <c:forEach var="cat" items="${faqCategories}">
                            <option value="${cat}">${cat}</option>
                        </c:forEach>
                    </select>
                </div>
            </c:if>
            <div>
                <label class="mb-1.5 block text-sm font-semibold text-slate-900">제목</label>
                <input type="text" id="itemTitle" placeholder="제목을 입력하세요"
                       class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
            </div>
            <div>
                <label class="mb-1.5 block text-sm font-semibold text-slate-900">내용</label>
                <textarea id="itemContent" rows="6" placeholder="내용을 입력하세요"
                          class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400"></textarea>
            </div>
            <div class="mt-2 flex justify-end gap-2">
                <button onclick="closeModal('writeModal')"
                        class="rounded-xl bg-slate-100 px-4 py-2.5 font-semibold text-slate-600 transition hover:bg-slate-200">취소</button>
                <button onclick="saveItem()"
                        class="rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">저장</button>
            </div>
        </div>
    </div>
</div>

<!-- 삭제 확인 모달 -->
<div id="confirmModal" class="modal-backdrop hidden" onclick="closeModal('confirmModal')">
    <div class="modal-box" onclick="event.stopPropagation()">
        <div class="mb-5 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-slate-900">삭제 확인</h2>
            <button onclick="closeModal('confirmModal')" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>
        <p id="confirmMessage" class="text-sm text-slate-600"></p>
        <div class="mt-5 flex justify-end gap-2">
            <button onclick="closeModal('confirmModal')"
                    class="rounded-xl bg-slate-100 px-4 py-2.5 font-semibold text-slate-600 transition hover:bg-slate-200">취소</button>
            <button id="confirmOkBtn"
                    class="rounded-xl bg-red-500 px-4 py-2.5 font-semibold text-white transition hover:bg-red-600">삭제</button>
        </div>
    </div>
</div>

<script>
const ctx        = '${ctx}';
const currentTab = '${currentTab}';
const apiBase    = currentTab === 'faq' ? `${ctx}/admin/faqs` : `${ctx}/admin/notices`;
</script>
<script src="${ctx}/js/common.js"></script>
<script src="${ctx}/js/admin/noticeFaq.js"></script>
</body>
</html>
