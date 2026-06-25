/*===============================================
    mypage.js
    - 마이페이지 전용 JS
    - 의존: common.js (fetchJSON, showToast, openModal, closeModal)
    - ctx 변수: mypage.jsp 에서 전역으로 주입 (const ctx = '...')
===============================================*/

/* ── 탭 전환 ── */
// tab: 'profile' | 'favorites' | 'inquiries'
function switchMypageTab(tab)
{
    // 탭 버튼 active 상태 전환 (data-mytab 속성 기준)
    document.querySelectorAll('.mypage-tab').forEach(btn =>
    {
        btn.classList.toggle('active', btn.dataset.mytab === tab);
    });

    // 각 패널 표시/숨김
    const panels = {
        profile:   'panelProfile',
        favorites: 'panelFavorites',
        plans:     'panelPlans',
        reviews:   'panelReviews',
        inquiries: 'panelInquiries'
    };
    Object.entries(panels).forEach(([key, id]) =>
    {
        const el = document.getElementById(id);
        if (el) el.classList.toggle('hidden', key !== tab);
    });

    // 패널 전환 후 Lucide 아이콘 재초기화 (동적 패널에 숨어있던 아이콘 렌더링)
    if (window.lucide) lucide.createIcons();
}


/* ── 닉네임 중복 확인 (정보수정용 — 자기 자신 제외) ── */
let nickChecked  = false;   // 중복확인 완료 여부
let originalNick = '';      // 페이지 로드 시 원래 닉네임 저장 (변경 여부 판단용)

async function checkProfileNickname()
{
    const nickname = document.getElementById('profileNickname').value.trim();
    if (!nickname) { showNickMsg('닉네임을 입력해주세요', false); return; }

    // 원래 닉네임과 동일하면 서버 요청 없이 통과
    if (nickname === originalNick)
    {
        showNickMsg('현재 사용 중인 닉네임입니다', true);
        nickChecked = true;
        return;
    }

    try
    {
        const data = await fetchJSON(`${ctx}/member/checkNicknameUpdate?nickname=${encodeURIComponent(nickname)}`);
        if (data.available)
        {
            showNickMsg('사용 가능한 닉네임입니다', true);
            nickChecked = true;
        }
        else
        {
            showNickMsg('이미 사용 중인 닉네임입니다', false);
            nickChecked = false;
        }
    }
    catch (e)
    {
        showToast('중복확인 중 오류가 발생했습니다.', 2000, 'error');
    }
}

// 닉네임 입력 변경 시 확인 상태 초기화
document.addEventListener('DOMContentLoaded', () =>
{
    const nicknameInput = document.getElementById('profileNickname');
    if (nicknameInput)
    {
        originalNick = nicknameInput.value.trim();
        nicknameInput.addEventListener('input', () =>
        {
            nickChecked = false;
            document.getElementById('nicknameMsg').classList.add('hidden');
        });
    }

    if (window.lucide) lucide.createIcons();
});


/* ── 정보 저장 ── */
async function saveProfile()
{
    const nickname = document.getElementById('profileNickname').value.trim();
    const pw       = document.getElementById('profilePw').value.trim();

    // 닉네임이 변경됐는데 중복확인 안 한 경우
    if (nickname !== originalNick && !nickChecked)
    {
        showNickMsg('닉네임 중복확인을 해주세요', false);
        return;
    }

    const body = {
        name:     document.getElementById('profileName').value.trim(),
        nickname: nickname,
        email:    document.getElementById('profileEmail').value.trim(),
        phoneNo:  document.getElementById('profilePhone').value.trim()
    };
    if (pw) body.pw = pw;

    try
    {
        await fetchJSON(`${ctx}/member/update`, {
            method:  'POST',
            headers: { 'Content-Type': 'application/json' },
            body:    JSON.stringify(body)
        });
        showToast('정보가 저장되었습니다.');

        // 저장 성공 후 상태 갱신
        originalNick = nickname;
        nickChecked  = false;
        document.getElementById('profilePw').value = '';
        document.getElementById('nicknameMsg').classList.add('hidden');
    }
    catch (e)
    {
        showToast('저장 중 오류가 발생했습니다.', 2000, 'error');
    }
}


/* ── 닉네임 메시지 표시 헬퍼 ── */
function showNickMsg(text, ok)
{
    const el = document.getElementById('nicknameMsg');
    el.textContent = text;
    el.className   = `mt-1 text-sm ${ok ? 'text-emerald-500' : 'text-red-400'}`;
    el.classList.remove('hidden');
}


/* ── 회원 탈퇴 ── */
async function submitWithdraw()
{
    const pw = document.getElementById('withdrawPw').value.trim();
    const msg = document.getElementById('withdrawMsg');

    if (!pw)
    {
        msg.textContent = '비밀번호를 입력해주세요';
        msg.classList.remove('hidden');
        return;
    }

    try
    {
        const data = await fetchJSON(`${ctx}/member/withdraw`, {
            method:  'POST',
            headers: { 'Content-Type': 'application/json' },
            body:    JSON.stringify({ pw })
        });

        if (data.result === 'ok')
        {
            // 탈퇴 완료 — 로그인 페이지로 이동
            location.href = `${ctx}/login`;
        }
        else
        {
            // 비밀번호 불일치
            msg.textContent = data.msg || '처리 중 오류가 발생했습니다.';
            msg.classList.remove('hidden');
        }
    }
    catch (e)
    {
        msg.textContent = '처리 중 오류가 발생했습니다.';
        msg.classList.remove('hidden');
    }
}


/* ── 탈퇴 모달 닫힐 때 입력값·에러 메시지 초기화 ── */
document.addEventListener('DOMContentLoaded', () =>
{
    const modal = document.getElementById('withdrawModal');
    if (!modal) return;

    // MutationObserver 로 hidden 클래스 추가 시점을 감지하여 초기화
    new MutationObserver(() =>
    {
        if (modal.classList.contains('hidden'))
        {
            document.getElementById('withdrawPw').value = '';
            document.getElementById('withdrawMsg').classList.add('hidden');
        }
    }).observe(modal, { attributes: true, attributeFilter: ['class'] });
});


/* ── 문의 등록 ── */
async function submitInquiry()
{
    const qnaTypeCd  = document.getElementById('inqCategory').value;
    const qnaTitle   = document.getElementById('inqTitle').value.trim();
    const qnaContent = document.getElementById('inqContent').value.trim();

    if (!qnaTitle)   { showToast('문의 제목을 입력해주세요.', 2000, 'error'); return; }
    if (!qnaContent) { showToast('문의 내용을 입력해주세요.', 2000, 'error'); return; }

    try
    {
        await fetchJSON(`${ctx}/qna/question`, {
            method:  'POST',
            headers: { 'Content-Type': 'application/json' },
            body:    JSON.stringify({ qnaTypeCd, qnaTitle, qnaContent })
        });

        closeModal('writeInquiryModal');
        showToast('문의가 접수되었습니다.');

        // 입력값 초기화
        document.getElementById('inqTitle').value   = '';
        document.getElementById('inqContent').value = '';

        // 문의 내역 탭으로 전환하여 새 문의 확인 (페이지 새로고침)
        location.reload();
    }
    catch (e)
    {
        showToast('문의 등록 중 오류가 발생했습니다.', 2000, 'error');
    }
}
