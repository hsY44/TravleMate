<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<c:set var="activePage" value="qna"/>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 문의하기</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/user.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen bg-slate-50">
    <%@ include file="/WEB-INF/views/common/sidebar_user.jsp" %>

    <main class="mx-auto w-full max-w-2xl flex-1 p-6">
        <h1 class="mb-6 text-2xl font-bold text-slate-900">문의하기</h1>

        <div class="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm">
            <!--
                form action 없음: JS(submitQnaForm)에서 fetch로 POST /qna/question 요청
            -->
            <form id="qnaForm" class="flex flex-col gap-4">
                <div>
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">카테고리</label>
                    <select id="qnaCategory"
                            class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                        <!-- inquiryCategories: QnaController에서 model에 담아온 QnaTypeVo 목록 -->
                        <c:forEach var="cat" items="${inquiryCategories}">
                            <option value="${cat.qnaTypeCd}">${cat.qnaTypeNm}</option>
                        </c:forEach>
                    </select>
                </div>
                <div>
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">제목</label>
                    <input type="text" id="qnaTitle" placeholder="문의 제목을 입력해주세요"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                </div>
                <div>
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">내용</label>
                    <textarea id="qnaContent" rows="8" placeholder="문의 내용을 입력해주세요"
                              class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400 resize-none"></textarea>
                </div>
                <div class="flex justify-end gap-2 pt-2">
                    <a href="${pageContext.request.contextPath}/mypage"
                       class="rounded-xl bg-slate-100 px-5 py-2.5 font-semibold text-slate-600 transition hover:bg-slate-200">취소</a>
                    <button type="button" onclick="submitQnaForm()"
                            class="rounded-xl bg-sky-500 px-5 py-2.5 font-semibold text-white transition hover:bg-sky-600">등록</button>
                </div>
            </form>
        </div>
    </main>
</div>

<script>const ctx = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/dist/js/common.js"></script>
<script>
async function submitQnaForm()
{
    const qnaTypeCd  = document.getElementById('qnaCategory').value;
    const qnaTitle   = document.getElementById('qnaTitle').value.trim();
    const qnaContent = document.getElementById('qnaContent').value.trim();

    if (!qnaTitle)   { showToast('문의 제목을 입력해주세요.', 2000, 'error'); return; }
    if (!qnaContent) { showToast('문의 내용을 입력해주세요.', 2000, 'error'); return; }

    try
    {
        await fetchJSON(`${ctx}/qna/question`, {
            method:  'POST',
            headers: { 'Content-Type': 'application/json' },
            body:    JSON.stringify({ qnaTypeCd, qnaTitle, qnaContent })
        });
        // 등록 완료 후 마이페이지 문의 내역 탭으로 이동
        location.href = `${ctx}/mypage`;
    }
    catch (e)
    {
        showToast('문의 등록 중 오류가 발생했습니다.', 2000, 'error');
    }
}
</script>
</body>
</html>
