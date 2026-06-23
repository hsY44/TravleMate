/* ═══════════════════════════════════════════
   plans.js  —  plans.jsp 전용 스크립트
   ctx 는 JSP 에서 인라인으로 주입
═══════════════════════════════════════════ */

/* ── 탭 전환 ── */
function switchPlanTab(tab) {
    document.querySelectorAll('[data-panel]').forEach(p => {
        p.classList.toggle('hidden', p.dataset.panel !== tab);
    });
    document.querySelectorAll('[data-tab]').forEach(b => {
        b.classList.toggle('active', b.dataset.tab === tab);
    });
    const filterTab = document.getElementById('filterTab');
    if (filterTab) filterTab.value = tab;
}

/* ── 새 계획 만들기 ── */
async function submitNewPlan() {
    const title     = document.getElementById('newPlanTitle').value.trim();
    const theme     = document.getElementById('newPlanTheme').value;
    const startDate = document.getElementById('newPlanStart').value;
    const endDate   = document.getElementById('newPlanEnd').value;
    const overview  = document.getElementById('newPlanOverview').value.trim();

    if (!title)              { showToast('여행 제목을 입력하세요.',       2000, 'error'); return; }
    if (!startDate)          { showToast('시작일을 선택하세요.',          2000, 'error'); return; }
    if (!endDate)            { showToast('종료일을 선택하세요.',          2000, 'error'); return; }
    if (endDate < startDate) { showToast('종료일이 시작일보다 빠릅니다.', 2000, 'error'); return; }

    try {
        const res = await fetchJSON(ctx + '/plans', {
            method: 'POST',
            body: JSON.stringify({ title, theme, startDate, endDate, overview })
        });
        location.href = ctx + '/plans/' + res.id;
    } catch (e) {
        showToast(e.message || '계획 생성에 실패했습니다.', 2000, 'error');
    }
}

/* ── 초대 코드 입력 ── */
// 16자리 검증 후 POST /plans/join → 성공 시 해당 계획 상세로 이동
async function submitInviteCode() {
    const input      = document.getElementById('inviteCodeInput');
    const inviteCode = input ? input.value.trim() : '';

    if (inviteCode.length !== 16) {
        showToast('초대 코드는 16자리입니다.', 2000, 'error');
        return;
    }

    try {
        const res = await fetchJSON(ctx + '/plans/join', {
            method: 'POST',
            body: JSON.stringify({ inviteCode })
        });
        location.href = ctx + '/plans/' + res.id;
    } catch (e) {
        showToast(e.message || '참여에 실패했습니다.', 2000, 'error');
    }
}

/* ── 초기화 ── */
document.addEventListener('DOMContentLoaded', () => {
    const input = document.getElementById('inviteCodeInput');
    const count = document.getElementById('inviteCodeCount');
    if (input && count) {
        input.addEventListener('input', () => {
            count.textContent = input.value.length + ' / 16';
        });
    }
});
