<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="ctx"        value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="reports"/>
<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 신고 내역</title>
    <link rel="stylesheet" href="${ctx}/dist/css/admin.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_admin.jsp" %>

    <main class="flex-1 p-6">
        <div class="mx-auto max-w-6xl">
            <h1 class="mb-6 text-2xl font-bold text-slate-900">신고 내역</h1>

            <!-- 필터 -->
            <form action="${ctx}/admin/reports" method="get" class="mb-4 flex flex-wrap gap-2">
                <!-- 카테고리 필터 -->
                <select name="category"
                        class="rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                    <option value="">전체 카테고리</option>
                    <c:forEach var="cat" items="${reportCategories}">
                        <option value="${cat}" ${param.category eq cat ? 'selected' : ''}>${cat}</option>
                    </c:forEach>
                </select>
                <!-- 처리 상태 필터 -->
                <select name="status"
                        class="rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                    <option value="">전체 상태</option>
                    <option value="pending"  ${param.status eq 'pending'  ? 'selected' : ''}>미처리</option>
                    <option value="resolved" ${param.status eq 'resolved' ? 'selected' : ''}>처리완료</option>
                </select>
                <button type="submit"
                        class="rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">검색</button>
            </form>

            <!-- 신고 목록 테이블 -->
            <div class="overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>번호</th>
                            <th>카테고리</th>
                            <th>신고자</th>
                            <th>피신고 리뷰</th>
                            <th>신고일</th>
                            <th>상태</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${reports}">
                            <tr>
                                <td class="text-slate-400">${r.no}</td>
                                <td class="whitespace-nowrap">
                                    <span class="rounded-full bg-sky-100 px-2 py-0.5 text-xs font-semibold text-sky-600">${r.category}</span>
                                </td>
                                <td class="whitespace-nowrap">${r.reporter}</td>
                                <td class="max-w-xs truncate">${r.reviewContentShort}</td>
                                <td class="whitespace-nowrap">
                                    <fmt:formatDate value="${r.reportedAt}" pattern="yyyy-MM-dd"/>
                                </td>
                                <td class="whitespace-nowrap">
                                    <!-- 처리 상태에 따라 뱃지 클래스 분기 -->
                                    <span class="rounded-full px-2 py-0.5 text-xs font-semibold
                                        ${r.status eq 'pending' ? 'badge-pending' : 'badge-resolved'}">
                                        <c:choose>
                                            <c:when test="${r.status eq 'pending'}">미처리</c:when>
                                            <c:otherwise>처리완료</c:otherwise>
                                        </c:choose>
                                    </span>
                                </td>
                                <td class="whitespace-nowrap">
                                    <button onclick="openReportDetail(${r.reportId})"
                                            class="rounded-lg bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-200">상세보기</button>
                                </td>
                            </tr>
                        </c:forEach>
                        <!-- 신고 내역 없음 -->
                        <c:if test="${empty reports}">
                            <tr>
                                <td colspan="7" class="py-10 text-center text-slate-400">신고 내역이 없습니다.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </main>
</div>

<!-- 신고 상세 모달 -->
<div id="reportDetailModal" class="modal-backdrop hidden" onclick="closeModal('reportDetailModal')">
    <div class="modal-box" onclick="event.stopPropagation()">
        <div class="mb-5 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-slate-900">신고 상세</h2>
            <button onclick="closeModal('reportDetailModal')" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>
        <div id="reportDetailContent">
            <!-- JS로 채워짐 -->
        </div>
    </div>
</div>

<!-- 제재 모달 -->
<div id="sanctionModal" class="modal-backdrop hidden" onclick="closeModal('sanctionModal')">
    <div class="modal-box" onclick="event.stopPropagation()">
        <div class="mb-5 flex items-center justify-between">
            <h2 class="text-lg font-semibold text-slate-900">회원 제재</h2>
            <button onclick="closeModal('sanctionModal')" class="text-slate-400 hover:text-slate-600">
                <i data-lucide="x" class="h-5 w-5"></i>
            </button>
        </div>
        <input type="hidden" id="sanctionMemberId">
        <div id="sanctionMemberInfo" class="mb-4 rounded-xl bg-slate-50 p-3 text-sm text-slate-600"></div>

        <label class="mb-1.5 block text-sm font-semibold text-slate-900">제재 강도</label>
        <div class="mb-4 flex gap-2">
            <button class="sanction-level-btn selected" data-level="1" onclick="selectLevel(this)">1일 정지</button>
            <button class="sanction-level-btn" data-level="3" onclick="selectLevel(this)">3일 정지</button>
            <button class="sanction-level-btn" data-level="7" onclick="selectLevel(this)">7일 정지</button>
        </div>

        <label class="mb-1.5 block text-sm font-semibold text-slate-900">사유</label>
        <select id="sanctionReason"
                class="mb-4 w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
            <option>광고/홍보</option>
            <option>부적절한 내용</option>
            <option>부적절한 닉네임</option>
        </select>

        <label class="mb-1.5 block text-sm font-semibold text-slate-900">관리자 코멘트</label>
        <textarea id="sanctionComment" rows="3" placeholder="제재 사유에 대한 메모를 남겨주세요"
                  class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400"></textarea>

        <div class="mt-5 flex justify-end gap-2">
            <button onclick="closeModal('sanctionModal')"
                    class="rounded-xl bg-slate-100 px-4 py-2.5 font-semibold text-slate-600 transition hover:bg-slate-200">취소</button>
            <button onclick="applySanction()"
                    class="rounded-xl bg-red-500 px-4 py-2.5 font-semibold text-white transition hover:bg-red-600">제재 적용</button>
        </div>
    </div>
</div>

<script>const ctx = '${pageContext.request.contextPath}';</script>
<script src="${ctx}/dist/js/common.js"></script>
<script src="${ctx}/dist/js/admin/reports.js"></script>
</body>
</html>
