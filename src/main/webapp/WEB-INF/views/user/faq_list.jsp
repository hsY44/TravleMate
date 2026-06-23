<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<c:set var="activePage" value="faq"/>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 자주 묻는 질문</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/user.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_user.jsp" %>

    <main class="mx-auto w-full max-w-3xl flex-1 p-6">
        <h1 class="mb-6 text-2xl font-bold text-slate-900">자주 묻는 질문</h1>

        <!-- 카테고리 필터 탭 -->
        <div class="mb-5 flex flex-wrap gap-2">
            <!-- 전체 탭 -->
            <a href="${pageContext.request.contextPath}/faq/list"
               class="rounded-full px-4 py-1.5 text-sm font-semibold transition
                   ${empty selectedType ? 'bg-sky-500 text-white' : 'bg-slate-100 text-slate-600 hover:bg-slate-200'}">
                전체
            </a>
            <!-- 카테고리별 탭 — faqTypes: Controller 에서 중복 제거해 전달 -->
            <c:forEach var="ft" items="${faqTypes}">
                <a href="${pageContext.request.contextPath}/faq/list?type=${ft.faqTypeCd}"
                   class="rounded-full px-4 py-1.5 text-sm font-semibold transition
                       ${selectedType eq ft.faqTypeCd ? 'bg-sky-500 text-white' : 'bg-slate-100 text-slate-600 hover:bg-slate-200'}">
                    ${ft.faqTypeNm}
                </a>
            </c:forEach>
        </div>

        <c:choose>
            <c:when test="${not empty faqs}">
                <!--
                    아코디언 UI
                    - 각 항목 클릭 시 답변 영역 토글
                    - JS: toggleFaq(id) — 하단 인라인 스크립트
                -->
                <div class="flex flex-col gap-2">
                    <c:forEach var="faq" items="${faqs}" varStatus="vs">
                        <div class="overflow-hidden rounded-2xl border border-slate-200 bg-white shadow-sm">
                            <button onclick="toggleFaq(${faq.faqNo})"
                                    class="flex w-full items-center justify-between gap-3 px-5 py-4 text-left transition hover:bg-slate-50">
                                <div class="flex items-center gap-2 min-w-0">
                                    <span class="rounded-full bg-sky-100 px-2 py-0.5 text-xs font-semibold text-sky-600 shrink-0">${faq.faqTypeNm}</span>
                                    <span class="font-semibold text-slate-900">${faq.faqQuestion}</span>
                                </div>
                                <i data-lucide="chevron-down" id="icon-${faq.faqNo}"
                                   class="h-4 w-4 shrink-0 text-slate-400 transition-transform duration-200"></i>
                            </button>
                            <!-- 답변 영역 — 기본 hidden, toggleFaq 로 토글 -->
                            <div id="answer-${faq.faqNo}" class="hidden border-t border-slate-100 bg-slate-50 px-5 py-4">
                                <div class="whitespace-pre-wrap text-sm leading-relaxed text-slate-600">${faq.faqAnswer}</div>
                            </div>
                        </div>
                    </c:forEach>
                </div>

            </c:when>
            <c:otherwise>
                <div class="flex flex-col items-center justify-center rounded-2xl border border-dashed border-slate-200 bg-white py-20 text-center">
                    <i data-lucide="help-circle" class="mb-4 h-10 w-10 text-slate-300"></i>
                    <p class="text-sm text-slate-400">등록된 FAQ가 없습니다</p>
                </div>
            </c:otherwise>
        </c:choose>

    </main>
</div>

<script>const ctx = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/dist/js/common.js"></script>
<script>
/* FAQ 아코디언 토글 */
function toggleFaq(id)
{
    const answer = document.getElementById('answer-' + id);
    const icon   = document.getElementById('icon-'   + id);
    const open   = answer.classList.toggle('hidden') === false;
    // 화살표 아이콘 회전 (열림: 180도)
    icon.style.transform = open ? 'rotate(180deg)' : '';
}
</script>
</body>
</html>
