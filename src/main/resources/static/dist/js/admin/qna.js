/* admin/qna.js
   qna.jsp 드로어 / 답변 모달 로직
   ctx 는 qna.jsp 인라인 스크립트에서 주입
*/

let currentQnaReqNo = null;

function openDrawer(qnaReqNo) {
    currentQnaReqNo = qnaReqNo;
    document.getElementById('drawerContent').innerHTML =
        '<p class="text-center text-sm text-slate-400">로딩 중...</p>';

    document.getElementById('drawerBackdrop').classList.remove('hidden');
    document.getElementById('drawerPanel').classList.remove('closed');

    fetch(ctx + '/admin/qna/' + qnaReqNo)
        .then(res => {
            if (!res.ok) throw new Error('HTTP ' + res.status);
            return res.json();
        })
        .then(q => {
            const statusBadge = q.statusCd === 'ST002'
                ? '<span class="rounded-full bg-emerald-100 px-2 py-0.5 text-xs font-semibold text-emerald-600">답변완료</span>'
                : '<span class="rounded-full bg-amber-100 px-2 py-0.5 text-xs font-semibold text-amber-600">답변대기</span>';

            const answerSection = q.statusCd === 'ST002' && q.ansContent
                ? '<div class="rounded-xl bg-emerald-50 p-4">'
                    + '<p class="mb-2 text-xs font-semibold text-emerald-600">관리자 답변</p>'
                    + '<p class="whitespace-pre-wrap text-sm text-slate-700">' + escapeHtml(q.ansContent) + '</p>'
                  + '</div>'
                : '<button onclick="openAnswerModal(' + q.qnaReqNo + ')"'
                    + ' class="w-full rounded-xl bg-sky-500 py-2.5 text-sm font-semibold text-white hover:bg-sky-600">'
                    + '답변 등록</button>';

            document.getElementById('drawerContent').innerHTML =
                '<div class="flex flex-col gap-1">'
                    + '<div class="flex items-center gap-2">' + statusBadge
                        + '<span class="rounded-full bg-sky-100 px-2 py-0.5 text-xs font-semibold text-sky-600">'
                        + escapeHtml(q.qnaTypeNm) + '</span>'
                    + '</div>'
                    + '<h4 class="mt-1 text-base font-semibold text-slate-900">' + escapeHtml(q.qnaTitle) + '</h4>'
                    + '<p class="text-xs text-slate-400">' + (q.createDt || '') + ' · ' + escapeHtml(q.memberNickname) + '</p>'
                + '</div>'
                + '<hr class="border-slate-100">'
                + '<p class="whitespace-pre-wrap text-sm leading-relaxed text-slate-700">' + escapeHtml(q.qnaContent) + '</p>'
                + answerSection;

            if (typeof lucide !== 'undefined') { lucide.createIcons(); }
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

function openAnswerModal(qnaReqNo) {
    document.getElementById('answerQnaReqNo').value = qnaReqNo;
    document.getElementById('answerContent').value  = '';
    document.getElementById('answerMsg').classList.add('hidden');
    const m = document.getElementById('answerModal');
    m.classList.remove('hidden');
    m.classList.add('flex');
}

function closeAnswerModal() {
    const m = document.getElementById('answerModal');
    m.classList.add('hidden');
    m.classList.remove('flex');
}

function submitAnswer() {
    const qnaReqNo   = document.getElementById('answerQnaReqNo').value;
    const ansContent = document.getElementById('answerContent').value.trim();
    const msg        = document.getElementById('answerMsg');

    if (!ansContent) {
        msg.textContent = '답변 내용을 입력하세요.';
        msg.classList.remove('hidden');
        return;
    }

    fetch(ctx + '/admin/qna/' + qnaReqNo + '/answer', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ ansContent })
    })
    .then(r => r.json())
    .then(data => {
        if (data.result === 'ok') { location.reload(); }
        else {
            msg.textContent = '등록 실패';
            msg.classList.remove('hidden');
        }
    });
}

function escapeHtml(str) {
    if (!str) return '';
    return str.replace(/&/g, '&amp;')
              .replace(/</g, '&lt;')
              .replace(/>/g, '&gt;')
              .replace(/"/g, '&quot;');
}
