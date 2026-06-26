/* admin/members.js */

function escapeHtml(str) {
    if (!str) return '';
    return str.replace(/&/g, '&amp;')
              .replace(/</g, '&lt;')
              .replace(/>/g, '&gt;')
              .replace(/"/g, '&quot;');
}

function openDrawer(memberId) {
    // 드로어를 먼저 열고 로딩 표시
    document.getElementById('drawerContent').innerHTML =
        '<p class="text-center text-sm text-slate-400">로딩 중...</p>';
    document.getElementById('drawerBackdrop').classList.remove('hidden');
    document.getElementById('drawerPanel').classList.remove('closed');

    fetch(ctx + '/admin/member/' + memberId)
        .then(res => {
            if (!res.ok) throw new Error('HTTP ' + res.status);
            return res.json();
        })
        .then(data => {
            document.getElementById('drawerContent').innerHTML = `
                <dl class="flex flex-col gap-4">
                    <div>
                        <dt class="mb-0.5 text-xs font-semibold text-slate-400">회원번호</dt>
                        <dd class="text-sm font-semibold text-slate-900">${data.memberNo ?? '-'}</dd>
                    </div>
                    <div>
                        <dt class="mb-0.5 text-xs font-semibold text-slate-400">아이디</dt>
                        <dd class="text-sm font-semibold text-slate-900">${escapeHtml(data.loginId) || '-'}</dd>
                    </div>
                    <div>
                        <dt class="mb-0.5 text-xs font-semibold text-slate-400">이름</dt>
                        <dd class="text-sm font-semibold text-slate-900">${escapeHtml(data.name) || '-'}</dd>
                    </div>
                    <div>
                        <dt class="mb-0.5 text-xs font-semibold text-slate-400">닉네임</dt>
                        <dd class="text-sm font-semibold text-slate-900">${escapeHtml(data.nickname) || '-'}</dd>
                    </div>
                    <div>
                        <dt class="mb-0.5 text-xs font-semibold text-slate-400">이메일</dt>
                        <dd class="text-sm font-semibold text-slate-900">${escapeHtml(data.email) || '-'}</dd>
                    </div>
                    <div>
                        <dt class="mb-0.5 text-xs font-semibold text-slate-400">전화번호</dt>
                        <dd class="text-sm font-semibold text-slate-900">${escapeHtml(data.phoneNo) || '-'}</dd>
                    </div>
                    <div>
                        <dt class="mb-0.5 text-xs font-semibold text-slate-400">가입일</dt>
                        <dd class="text-sm font-semibold text-slate-900">${escapeHtml(data.createDt) || '-'}</dd>
                    </div>
                </dl>`;
        })
        .catch(() => {
            document.getElementById('drawerContent').innerHTML =
                '<p class="text-sm text-red-400">불러오기 실패</p>';
        });
}

function closeDrawer() {
    document.getElementById('drawerBackdrop').classList.add('hidden');
    document.getElementById('drawerPanel').classList.add('closed');
}
