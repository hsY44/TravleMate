/* admin/reports.js */

function openReportDetail(reportId) {
    // stub: 추후 API 연동
    document.getElementById('reportDetailContent').innerHTML =
        `<p class="text-sm text-slate-500">신고 ID: ${reportId}</p>`;
    openModal('reportDetailModal');
}

function openSanction(memberId, nickname) {
    document.getElementById('sanctionMemberId').value = memberId;
    document.getElementById('sanctionMemberInfo').textContent = `대상: ${nickname}`;
    openModal('sanctionModal');
}

function selectLevel(btn) {
    document.querySelectorAll('.sanction-level-btn').forEach(b => b.classList.remove('selected'));
    btn.classList.add('selected');
}

function applySanction() {
    const memberId = document.getElementById('sanctionMemberId').value;
    const level    = document.querySelector('.sanction-level-btn.selected')?.dataset.level;
    const reason   = document.getElementById('sanctionReason').value;
    const comment  = document.getElementById('sanctionComment').value;

    fetchJSON(`${ctx}/admin/member/${memberId}/sanction`, {
        method: 'POST',
        body: JSON.stringify({ level, reason, comment })
    })
    .then(() => {
        closeModal('sanctionModal');
        showToast('제재가 적용되었습니다.');
        setTimeout(() => location.reload(), 1000);
    })
    .catch(err => showToast(`오류: ${err.message}`, 3000, 'error'));
}
