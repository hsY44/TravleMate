<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx"        value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="members"/>
<!DOCTYPE html>
<html lang="ko">
<head>
    <link rel="icon" href="data:;base64,iVBORw0KGgo=">
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 회원 상세</title>
    <link rel="stylesheet" href="${ctx}/dist/css/admin.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_admin.jsp" %>

    <main class="flex-1 p-6">
        <div class="mx-auto max-w-2xl">

            <!-- 헤더 -->
            <div class="mb-6 flex items-center gap-3">
                <a href="${ctx}/admin/members"
                   class="flex items-center gap-1 text-sm text-slate-400 transition hover:text-slate-600">
                    <i data-lucide="arrow-left" class="h-4 w-4"></i> 회원 목록
                </a>
                <h1 class="text-2xl font-bold text-slate-900">회원 상세</h1>
            </div>

            <!-- 상세 카드 -->
            <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
                <div class="mb-6 flex items-center justify-between gap-4">
                    <div class="flex items-center gap-4">
                        <div class="flex h-14 w-14 items-center justify-center rounded-full bg-sky-100">
                            <i data-lucide="user" class="h-7 w-7 text-sky-500"></i>
                        </div>
                        <div>
                            <p class="text-xl font-bold text-slate-900">${member.nickname}</p>
                            <p class="text-sm text-slate-400">${member.loginId}</p>
                        </div>
                    </div>
                    <button onclick="openSanction(${member.memberNo}, '${member.nickname}')"
                            class="flex items-center gap-1.5 rounded-xl bg-red-50 px-4 py-2 text-sm font-semibold text-red-500 hover:bg-red-100 transition">
                        <i data-lucide="shield-ban" class="h-4 w-4"></i> 제재
                    </button>
                </div>

                <dl class="grid grid-cols-1 gap-4 sm:grid-cols-2">
                    <div class="rounded-xl bg-slate-50 p-4">
                        <dt class="mb-1 text-xs font-semibold text-slate-400">회원번호</dt>
                        <dd class="text-sm font-semibold text-slate-900">${member.memberNo}</dd>
                    </div>
                    <div class="rounded-xl bg-slate-50 p-4">
                        <dt class="mb-1 text-xs font-semibold text-slate-400">이름</dt>
                        <dd class="text-sm font-semibold text-slate-900">${member.name}</dd>
                    </div>
                    <div class="rounded-xl bg-slate-50 p-4">
                        <dt class="mb-1 text-xs font-semibold text-slate-400">아이디</dt>
                        <dd class="text-sm font-semibold text-slate-900">${member.loginId}</dd>
                    </div>
                    <div class="rounded-xl bg-slate-50 p-4">
                        <dt class="mb-1 text-xs font-semibold text-slate-400">닉네임</dt>
                        <dd class="text-sm font-semibold text-slate-900">${member.nickname}</dd>
                    </div>
                    <div class="rounded-xl bg-slate-50 p-4">
                        <dt class="mb-1 text-xs font-semibold text-slate-400">이메일</dt>
                        <dd class="text-sm font-semibold text-slate-900">${member.email}</dd>
                    </div>
                    <div class="rounded-xl bg-slate-50 p-4">
                        <dt class="mb-1 text-xs font-semibold text-slate-400">전화번호</dt>
                        <dd class="text-sm font-semibold text-slate-900">${member.phoneNo}</dd>
                    </div>
                    <div class="rounded-xl bg-slate-50 p-4 sm:col-span-2">
                        <dt class="mb-1 text-xs font-semibold text-slate-400">가입일</dt>
                        <dd class="text-sm font-semibold text-slate-900">${member.createDt}</dd>
                    </div>
                </dl>
            </div>

        </div>
    </main>
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

<script>const ctx = '${ctx}';</script>
<script src="${ctx}/dist/js/common.js"></script>
<script src="${ctx}/dist/js/admin/reports.js"></script>
<script>
function openSanction(memberId, nickname) {
    document.getElementById('sanctionMemberId').value = memberId;
    document.getElementById('sanctionMemberInfo').textContent = '대상: ' + nickname;
    document.querySelector('.sanction-level-btn.selected')?.classList.remove('selected');
    document.querySelector('.sanction-level-btn[data-level="1"]').classList.add('selected');
    document.getElementById('sanctionComment').value = '';
    openModal('sanctionModal');
}
</script>
</body>
</html>
