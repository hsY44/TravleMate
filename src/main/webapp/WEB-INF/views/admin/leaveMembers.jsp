<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<c:set var="ctx"        value="${pageContext.request.contextPath}"/>
<c:set var="activePage" value="leaveMembers"/>
<!DOCTYPE html>
<html>
<head>
    <link rel="icon" href="data:;base64,iVBORw0KGgo=">
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 탈퇴 회원 관리</title>
    <link rel="stylesheet" href="${ctx}/dist/css/admin.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_admin.jsp" %>

    <main class="flex-1 p-6">
        <div class="mx-auto max-w-6xl">
            <h1 class="mb-6 text-2xl font-bold text-slate-900">탈퇴 회원 관리</h1>

            <div class="overflow-x-auto rounded-2xl border border-slate-200 bg-white shadow-sm">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>회원번호</th>
                            <th>아이디</th>
                            <th>이름</th>
                            <th>닉네임</th>
                            <th>이메일</th>
                            <th>전화번호</th>
                            <th>탈퇴일</th>
                            <th>관리</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="m" items="${leaveMembers}">
                            <tr>
                                <td class="text-slate-400">${m.memberNo}</td>
                                <td class="font-semibold text-slate-900">${m.loginId}</td>
                                <td>${m.name}</td>
                                <td>${m.nickname}</td>
                                <td>${m.email}</td>
                                <td>${m.phoneNo}</td>
                                <td class="whitespace-nowrap">${m.leaveDt}</td>
                                <td class="whitespace-nowrap">
                                    <button onclick="openDrawer(${m.memberNo})"
                                            class="rounded-lg bg-slate-100 px-2.5 py-1 text-xs font-semibold text-slate-600 hover:bg-slate-200">
                                        상세보기
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty leaveMembers}">
                            <tr>
                                <td colspan="8" class="py-10 text-center text-slate-400">탈퇴 회원이 없습니다.</td>
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

<!-- 탈퇴 회원 상세 드로어 -->
<div id="drawerBackdrop" class="drawer-backdrop hidden" onclick="closeDrawer()"></div>
<aside id="drawerPanel" class="drawer-panel closed">
    <div class="flex items-center justify-between border-b border-slate-200 p-4">
        <h3 class="font-semibold text-slate-900">탈퇴 회원 상세</h3>
        <button onclick="closeDrawer()" class="text-slate-400 hover:text-slate-600">
            <i data-lucide="x" class="h-5 w-5"></i>
        </button>
    </div>
    <div id="drawerContent" class="flex flex-1 flex-col gap-5 overflow-auto p-4">
        <p class="text-center text-sm text-slate-400">로딩 중...</p>
    </div>
</aside>

<script>const ctx = '${pageContext.request.contextPath}';</script>
<script src="${ctx}/dist/js/common.js"></script>
<script type="text/javascript">
	function openDrawer(memberNo)
	{
	    document.getElementById('drawerContent').innerHTML = '<p class="text-center text-sm text-slate-400">로딩 중...</p>';
	
	    const backdrop = document.getElementById('drawerBackdrop');
	    const panel    = document.getElementById('drawerPanel');
	    backdrop.classList.remove('hidden');
	    panel.classList.remove('closed');
	
	    fetch(ctx + '/admin/leaveMember/' + memberNo)
	        .then(r => r.json())
	        .then(m => {

	            let html = '<dl class="flex flex-col gap-4">';

	            html += row('회원번호', m.memberNo);
	            html += row('아이디', m.loginId);
	            html += row('이름', m.name);
	            html += row('닉네임', m.nickname);
	            html += row('이메일', m.email);
	            html += row('전화번호', m.phoneNo);
	            html += row('탈퇴일', m.leaveDt);

	            html += '</dl>';

	            document.getElementById('drawerContent').innerHTML = html;
	        });
	}
	
	function closeDrawer()
	{
	    document.getElementById('drawerBackdrop').classList.add('hidden');
	    document.getElementById('drawerPanel').classList.add('closed');
	}
	
	function row(label, value)
	{
	    return '<div>'
	        + '<dt class="mb-0.5 text-xs font-semibold text-slate-400">' + label + '</dt>'
	        + '<dd class="text-sm font-semibold text-slate-900">' + (value || '-') + '</dd>'
	        + '</div>';
	}
</script>
</body>
</html>
