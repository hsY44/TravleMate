<%@ page contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 로그인</title>
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen items-center justify-center px-4">
    <div class="w-full max-w-md">
        <div class="mx-auto w-full rounded-2xl border border-slate-200 bg-white p-8 shadow-sm">

            <!-- 로고 -->
            <div class="mb-7 flex flex-col items-center gap-3">
                <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-sky-500">
                    <i data-lucide="plane" class="h-6 w-6 text-white"></i>
                </div>
                <h1 class="text-2xl font-bold text-sky-500">트래블메이트</h1>
                <p class="text-sm text-slate-400">함께 만드는 여행 계획</p>
            </div>

            <!-- 탭: 회원/관리자 로그인 전환 (JS: switchLoginTab) -->
            <div class="mb-6 flex border-b border-slate-200">
                <button id="tabMember" onclick="switchLoginTab('member')"
                        class="tab-btn active flex-1">회원 로그인</button>
                <button id="tabAdmin"  onclick="switchLoginTab('admin')"
                        class="tab-btn flex-1">관리자 로그인</button>
            </div>

            <!-- 서버 측 로그인 실패 메시지 -->
            <c:if test="${not empty errorMsg}">
                <p class="mb-3 text-sm text-red-400">${errorMsg}</p>
            </c:if>

            <!--
                novalidate: HTML5 기본 유효성 검사 비활성화
                → JS(login.js)에서 직접 검증하기 위해 사용
            -->
            <form id="loginForm" action="${pageContext.request.contextPath}/login" method="post" class="flex flex-col gap-4" novalidate>

                <!-- 회원/관리자 구분값: JS에서 탭 전환 시 값 변경 -->
                <input type="hidden" name="role" id="roleInput" value="member">

                <div>
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">아이디</label>
                    <input type="text" name="loginId" id="loginId" placeholder="아이디를 입력하세요"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                    <!-- JS로 hidden 토글 -->
                    <p id="idError" class="mt-1 hidden text-sm text-red-400">아이디를 입력해주세요</p>
                </div>

                <div>
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">비밀번호</label>
                    <div class="relative">
                        <input type="password" name="password" id="password" placeholder="비밀번호를 입력하세요"
                               class="w-full rounded-xl border border-slate-200 px-3 py-2.5 pr-10 focus:outline-none focus:ring-2 focus:ring-sky-400">
                        <!--
                            비밀번호 표시/숨기기 토글 버튼
                            aria-label: 스크린 리더 접근성을 위한 버튼 설명
                            type="button": form submit 방지
                        -->
                        <button type="button" id="togglePw" aria-label="비밀번호 표시 전환"
                                class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600">
                            <i data-lucide="eye" class="h-5 w-5" id="eyeIcon"></i>
                        </button>
                    </div>
                    <p id="pwError" class="mt-1 hidden text-sm text-red-400">비밀번호를 입력해주세요</p>
                </div>

                <button type="submit"
                        class="w-full rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">
                    로그인
                </button>
            </form>

            <!-- 회원가입 링크 (관리자 탭에서는 JS로 숨김 처리) -->
            <!-- id="signupLink": login.js의 switchLoginTab()에서 display 제어 -->
            <div id="signupLink" class="mt-6 border-t border-slate-200 pt-5 text-center text-sm text-slate-400">
                아직 회원이 아니신가요?
                <a href="${pageContext.request.contextPath}/register" class="font-semibold text-sky-500 hover:text-sky-600">회원가입</a>
            </div>
        </div>
    </div>
</div>

<script>const ctx = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/dist/js/common.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/login.js"></script>
</body>
</html>
