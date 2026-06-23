// 상태 변수 
let currentStep = 1;
let idChecked   = false;    // 아이디 중복확인 완료 여부
let nickChecked = false;    // 닉네임 중복확인 완료 여부

// 아이디 중복확인 (AJAX) 
// MemberController GET /member/checkId?id=값 → { available: true|false }
async function checkId()
{
    const id = document.getElementById('regId').value.trim();
    if (!id) { showMsg('idMsg', '아이디를 입력해주세요', false); return; }

    try {
        const data = await fetchJSON(`${ctx}/member/checkId?id=${encodeURIComponent(id)}`);
        if (data.available) {
            showMsg('idMsg', '사용 가능한 아이디입니다', true);
            idChecked = true;
        } else {
            showMsg('idMsg', '이미 사용 중인 아이디입니다', false);
            idChecked = false;
        }
    } catch (e) {
        showToast('중복확인 중 오류가 발생했습니다.', 'error');
    }
}

// 닉네임 중복확인 (AJAX)
// MemberController GET /member/checkNickname?nickname=값 → { available: true|false }
async function checkNickname()
{
    const nickname = document.getElementById('regNickname').value.trim();
    if (!nickname) { showMsg('nicknameMsg', '닉네임을 입력해주세요', false); return; }

    try {
        const data = await fetchJSON(`${ctx}/member/checkNickname?nickname=${encodeURIComponent(nickname)}`);
        if (data.available) {
            showMsg('nicknameMsg', '사용 가능한 닉네임입니다', true);
            nickChecked = true;
        } else {
            showMsg('nicknameMsg', '이미 사용 중인 닉네임입니다', false);
            nickChecked = false;
        }
    } catch (e) {
        showToast('중복확인 중 오류가 발생했습니다.', 'error');
    }
}

// 메시지 표시 헬퍼 
// ok: true → 초록색(사용가능), false → 빨간색(오류)
function showMsg(elementId, text, ok)
{
    const el = document.getElementById(elementId);
    el.textContent = text;
    el.className = `mt-1 text-sm ${ok ? 'text-emerald-500' : 'text-red-400'}`;
    el.classList.remove('hidden');
}

// 다음 단계 
async function nextStep()
{
    if (currentStep === 1 && !validateStep1()) return;
    if (currentStep === 2)
    {
        if (!validateStep2()) return;
        // 마지막 단계 → 가입 처리 후 step3 이동
        await submitRegister();
        return;
    }
    currentStep++;
    renderStep();
}

// 이전 단계 
function prevStep()
{
    if (currentStep <= 1) return;
    currentStep--;
    renderStep();
}

// ○ Step 1 유효성 검증 (계정정보) 
function validateStep1()
{
    const id        = document.getElementById('regId').value.trim();
    const pw        = document.getElementById('regPw').value.trim();
    const pwConfirm = document.getElementById('regPwConfirm').value.trim();

    if (!id)        { showMsg('idMsg',        '아이디를 입력해주세요',          false); return false; }
    if (!idChecked) { showMsg('idMsg',        '아이디 중복확인을 해주세요',     false); return false; }
    if (!pw)        { showMsg('pwMsg',        '비밀번호를 입력해주세요',        false); return false; }
    if (pw !== pwConfirm)
    {
        showMsg('pwConfirmMsg', '비밀번호가 일치하지 않습니다', false);
        return false;
    }

    document.getElementById('pwMsg').classList.add('hidden');
    document.getElementById('pwConfirmMsg').classList.add('hidden');
    return true;
}

// ○ Step 2 유효성 검증 (개인정보)
function validateStep2()
{
    const name     = document.getElementById('regName').value.trim();
    const nickname = document.getElementById('regNickname').value.trim();
    const email    = document.getElementById('regEmail').value.trim();
    const phone    = document.getElementById('regPhone').value.trim();

    if (!name)         { showMsg('nameMsg',     '이름을 입력해주세요',              false); return false; }
    if (!nickname)     { showMsg('nicknameMsg', '닉네임을 입력해주세요',            false); return false; }
    if (!nickChecked)  { showMsg('nicknameMsg', '닉네임 중복확인을 해주세요',       false); return false; }

    // 이메일 형식 검증
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email))
    {
        showMsg('emailMsg', '올바른 이메일을 입력해주세요', false);
        return false;
    }

    // 휴대폰번호 형식 검증 (010-0000-0000 또는 010-000-0000)
    if (!phone || !/^\d{3}-\d{3,4}-\d{4}$/.test(phone))
    {
        showMsg('phoneMsg', '형식에 맞게 입력해주세요 (예: 010-0000-0000)', false);
        return false;
    }
    return true;
}

// ○ 회원가입 AJAX 제출 
// MemberController POST /register → JSON body
// 성공 시 { result: "ok" } 수신 후 step3(완료 화면) 표시
async function submitRegister()
{
    const body = {
        loginId:  document.getElementById('regId').value.trim(),
        pw:       document.getElementById('regPw').value.trim(),
        name:     document.getElementById('regName').value.trim(),
        nickname: document.getElementById('regNickname').value.trim(),
        email:    document.getElementById('regEmail').value.trim(),
        phoneNo:  document.getElementById('regPhone').value.trim()
    };

    try {
        await fetchJSON(`${ctx}/register`, { method: 'POST', body: JSON.stringify(body) });
        currentStep = 3;
        renderStep();
    } catch (e) {
        showToast('회원가입 중 오류가 발생했습니다. 다시 시도해주세요.', 'error');
    }
}

// 스텝 인디케이터 및 패널 렌더링 
function renderStep()
{
    // 단계별 패널 표시/숨김
    document.getElementById('step1').classList.toggle('hidden', currentStep !== 1);
    document.getElementById('step2').classList.toggle('hidden', currentStep !== 2);
    document.getElementById('step3').classList.toggle('hidden', currentStep !== 3);

    // step3(완료)에서는 이전/다음 버튼 영역 전체 숨김
    document.getElementById('stepBtns').classList.toggle('hidden', currentStep === 3);
    document.getElementById('prevBtn').disabled = (currentStep === 1);

    // step2에서 '다음' 버튼 텍스트를 '가입하기'로 변경
    document.getElementById('nextBtn').textContent = (currentStep === 2) ? '가입하기' : '다음';

    // 스텝 인디케이터 업데이트 (원, 라벨, 연결선)
    for (let i = 1; i <= 3; i++)
    {
        const circle = document.getElementById(`stepCircle${i}`);
        const label  = document.getElementById(`stepLabel${i}`);
        const done   = i < currentStep;
        const active = i === currentStep;

        // 현재 단계: 파란색 / 완료 단계: 초록색 / 미진행 단계: 회색
        circle.className = [
            'flex h-9 w-9 items-center justify-center rounded-full text-sm font-semibold',
            active ? 'bg-sky-500 text-white' : done ? 'bg-emerald-500 text-white' : 'bg-slate-200 text-slate-400'
        ].join(' ');

        label.className = `text-xs ${active ? 'font-semibold text-slate-900' : done ? 'font-semibold text-emerald-500' : 'text-slate-400'}`;

        // 연결선 (stepLine1: step1↔step2, stepLine2: step2↔step3)
        if (i < 3)
        {
            document.getElementById(`stepLine${i}`).classList.toggle('done', i < currentStep);
        }
    }

    // Lucide 아이콘 재초기화 (step3 완료 화면의 check-circle 아이콘)
    if (window.lucide) lucide.createIcons();
}
