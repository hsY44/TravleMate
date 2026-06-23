<%@ page contentType="text/html; charset=UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <%@ include file="/WEB-INF/views/common/head.jsp" %>
    <title>트래블메이트 — 회원가입</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/dist/css/user.css">
</head>
<body class="bg-slate-50">

<div class="flex min-h-screen items-center justify-center px-4 py-10">
    <div class="mx-auto w-full max-w-lg rounded-2xl border border-slate-200 bg-white p-8 shadow-sm">
        <h1 class="mb-6 text-center text-2xl font-bold text-sky-500">회원가입</h1>

        <!--
            스텝 인디케이터 (다단계 폼)
            총 3단계: 계정정보 → 개인정보 → 완료
            JS(register.js)에서 stepCircle, stepLabel, stepLine의 클래스를 동적으로 변경해 진행 상태 표시
        -->
        <div class="mb-7 flex items-center justify-center" id="stepIndicator">
            <!-- step 1 -->
            <div class="flex flex-col items-center gap-1.5">
                <div id="stepCircle1" class="flex h-9 w-9 items-center justify-center rounded-full bg-sky-500 text-sm font-semibold text-white">1</div>
                <span id="stepLabel1" class="text-xs font-semibold text-slate-900">계정정보</span>
            </div>
            <!-- 단계 연결선: JS에서 완료 단계 강조 처리 -->
            <div id="stepLine1" class="step-line mx-2 mb-5"></div>
            <!-- step 2 -->
            <div class="flex flex-col items-center gap-1.5">
                <div id="stepCircle2" class="flex h-9 w-9 items-center justify-center rounded-full bg-slate-200 text-sm font-semibold text-slate-400">2</div>
                <span id="stepLabel2" class="text-xs text-slate-400">개인정보</span>
            </div>
            <div id="stepLine2" class="step-line mx-2 mb-5"></div>
            <!-- step 3 -->
            <div class="flex flex-col items-center gap-1.5">
                <div id="stepCircle3" class="flex h-9 w-9 items-center justify-center rounded-full bg-slate-200 text-sm font-semibold text-slate-400">3</div>
                <span id="stepLabel3" class="text-xs text-slate-400">완료</span>
            </div>
        </div>

        <!-- ── Step 1: 계정정보 ── -->
        <div id="step1">
            <div class="flex flex-col gap-4">
                <!-- 아이디 + 중복 확인 (AJAX: checkId()) -->
                <div>
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">아이디</label>
                    <div class="flex gap-2">
                        <input type="text" id="regId" placeholder="아이디를 입력하세요"
                               class="flex-1 rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                        <button type="button" onclick="checkId()"
                                class="rounded-xl bg-slate-100 px-4 py-2.5 font-semibold text-slate-600 hover:bg-slate-200 transition">중복확인</button>
                    </div>
                    <!-- 중복 확인 결과 메시지: JS에서 text-red-400 / text-emerald-500 클래스로 결과 표시 -->
                    <p id="idMsg" class="mt-1 hidden text-sm"></p>
                </div>
                <!-- 비밀번호 -->
                <div>
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">비밀번호</label>
                    <input type="password" id="regPw" placeholder="비밀번호를 입력하세요"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                    <p id="pwMsg" class="mt-1 hidden text-sm text-red-400">비밀번호를 입력해주세요</p>
                </div>
                <!-- 비밀번호 확인: JS에서 regPw 값과 일치 여부 검증 -->
                <div>
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">비밀번호 확인</label>
                    <input type="password" id="regPwConfirm" placeholder="비밀번호를 다시 입력하세요"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                    <p id="pwConfirmMsg" class="mt-1 hidden text-sm text-red-400"></p>
                </div>
            </div>
        </div>

        <!-- ── Step 2: 개인정보 (초기 hidden → JS에서 표시) ── -->
        <div id="step2" class="hidden">
            <div class="flex flex-col gap-4">
                <!-- 이름 -->
                <div>
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">이름</label>
                    <input type="text" id="regName" placeholder="이름을 입력하세요"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                    <p id="nameMsg" class="mt-1 hidden text-sm text-red-400">이름을 입력해주세요</p>
                </div>
                <!-- 닉네임 + 중복 확인 (AJAX: checkNickname()) -->
                <div>
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">닉네임</label>
                    <div class="flex gap-2">
                        <input type="text" id="regNickname" placeholder="닉네임을 입력하세요"
                               class="flex-1 rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                        <button type="button" onclick="checkNickname()"
                                class="rounded-xl bg-slate-100 px-4 py-2.5 font-semibold text-slate-600 hover:bg-slate-200 transition">중복확인</button>
                    </div>
                    <p id="nicknameMsg" class="mt-1 hidden text-sm"></p>
                </div>
                <!--
                    type="email": 브라우저 기본 이메일 형식 힌트 제공
                    (novalidate 없으므로 폼 제출 시 브라우저 검증 작동)
                -->
                <div>
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">이메일</label>
                    <input type="email" id="regEmail" placeholder="example@email.com"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                    <p id="emailMsg" class="mt-1 hidden text-sm text-red-400"></p>
                </div>
                <!-- type="tel": 모바일에서 숫자 키패드 자동 노출 -->
                <div>
                    <label class="mb-1.5 block text-sm font-semibold text-slate-900">휴대폰번호</label>
                    <input type="tel" id="regPhone" placeholder="010-0000-0000"
                           class="w-full rounded-xl border border-slate-200 px-3 py-2.5 focus:outline-none focus:ring-2 focus:ring-sky-400">
                    <p id="phoneMsg" class="mt-1 hidden text-sm text-red-400"></p>
                </div>
            </div>
        </div>

        <!-- ── Step 3: 완료 화면 (초기 hidden → JS에서 표시) ── -->
        <div id="step3" class="hidden">
            <div class="flex flex-col items-center gap-4 py-6 text-center">
                <i data-lucide="check-circle" class="h-16 w-16 text-emerald-500"></i>
                <h2 class="text-lg font-semibold text-slate-900">회원가입이 완료되었습니다!</h2>
                <p class="text-sm text-slate-400">트래블메이트와 함께 여행 계획을 시작해보세요</p>
                <a href="${pageContext.request.contextPath}/login"
                   class="w-full rounded-xl bg-sky-500 px-4 py-2.5 text-center font-semibold text-white transition hover:bg-sky-600">
                    로그인하러 가기
                </a>
            </div>
        </div>

        <!--
            이전/다음 버튼
            - prevBtn: step1에서는 disabled (첫 단계이므로 이전 없음)
            - nextBtn: JS(nextStep/prevStep)에서 단계 전환 + 유효성 검증
            - step3 완료 화면에서는 JS로 이 버튼 영역 전체 숨김
            - disabled:opacity-40, disabled:cursor-not-allowed: Tailwind disabled 스타일
        -->
        <div id="stepBtns" class="mt-7 flex justify-end gap-2">
            <button id="prevBtn" onclick="prevStep()" disabled
                    class="rounded-xl bg-slate-100 px-4 py-2.5 font-semibold text-slate-600 transition hover:bg-slate-200 disabled:cursor-not-allowed disabled:opacity-40">
                이전
            </button>
            <button id="nextBtn" onclick="nextStep()"
                    class="rounded-xl bg-sky-500 px-4 py-2.5 font-semibold text-white transition hover:bg-sky-600">
                다음
            </button>
        </div>
    </div>
</div>

<script>const ctx = '${pageContext.request.contextPath}';</script>
<script src="${pageContext.request.contextPath}/dist/js/common.js"></script>
<script src="${pageContext.request.contextPath}/dist/js/register.js"></script>
</body>
</html>
