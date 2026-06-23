/* ── 모달 ── */
function openModal(id) {
    const el = document.getElementById(id);
    if (el) el.classList.remove('hidden');
}
function closeModal(id) {
    const el = document.getElementById(id);
    if (el) el.classList.add('hidden');
}

// backdrop 클릭 시 모달 닫기 - 모달 backdrop div에 data-modal-id 지정
document.addEventListener('click', (e) => {
    if (e.target.matches('[data-close-modal]')) {
        const id = e.target.closest('[data-modal-id]')?.dataset.modalId
               || e.target.dataset.closeModal;
        if (id) closeModal(id);
    }
});

/* ── 토스트 ── */
let _toastTimer = null;
function showToast(message, time = 2500 , type = 'success') {
    let toast = document.getElementById('_toast');
    if (!toast) {
        toast = document.createElement('div');
        toast.id = '_toast';
        toast.className = 'toast';
        document.body.appendChild(toast);
    }
    toast.textContent = message;
    toast.className = `toast ${type}`;
    requestAnimationFrame(() => toast.classList.add('show'));
    clearTimeout(_toastTimer);
    _toastTimer = setTimeout(() => toast.classList.remove('show'), time);
}

/* ── fetch JSON 헬퍼 ── */
async function fetchJSON(url, options = {}) {
    const defaults = {
        headers: { 'Content-Type': 'application/json' }
    };
    const res = await fetch(url, { ...defaults, ...options });
    if (!res.ok) {
        const text = await res.text().catch(() => '');
        throw new Error(text || res.status);
    }
    const ct = res.headers.get('content-type') || '';
    return ct.includes('application/json') ? res.json() : res.text();
}

/* ── 탭 전환 ── */
// tabGroupId: 탭 버튼 컨테이너의 id
// panelGroupId: 탭 패널 컨테이너의 id (생략 가능, 버튼과 패널이 data-tab 공유)
function initTabs(tabGroupId, onChange) {
    const container = document.getElementById(tabGroupId);
    if (!container) return;
    container.querySelectorAll('[data-tab]').forEach(btn => {
        btn.addEventListener('click', () => {
            const key = btn.dataset.tab;
            // 버튼 active 상태
            container.querySelectorAll('[data-tab]').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            // 패널 표시 (data-panel 속성을 가진 요소)
            document.querySelectorAll('[data-panel]').forEach(p => {
                p.classList.toggle('hidden', p.dataset.panel !== key);
            });
            if (onChange) onChange(key);
        });
    });
}

/* ── 확인 모달 ── */
// 단순 confirm 대신 커스텀 confirm 모달 사용
let _confirmCallback = null;
function openConfirm(message, onConfirm, danger = false) {
    document.getElementById('confirmMessage').textContent = message;
    const btn = document.getElementById('confirmOkBtn');
    btn.className = `rounded-xl px-4 py-2.5 font-semibold transition ${danger ? 'bg-red-500 text-white hover:bg-red-600' : 'bg-sky-500 text-white hover:bg-sky-600'}`;
    _confirmCallback = onConfirm;
    openModal('confirmModal');
}
document.addEventListener('DOMContentLoaded', () => {
    const btn = document.getElementById('confirmOkBtn');
    if (btn) {
        btn.addEventListener('click', () => {
            closeModal('confirmModal');
            if (_confirmCallback) _confirmCallback();
            _confirmCallback = null;
        });
    }
    // Lucide 아이콘 초기화
    if (window.lucide) lucide.createIcons();
});
