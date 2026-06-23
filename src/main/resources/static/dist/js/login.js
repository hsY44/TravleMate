/* ── 탭 전환 (회원 / 관리자) ── */
// role 값: login.jsp의 hidden input(roleInput) → 서버 로그인 분기에 사용
function switchLoginTab(role)
{
    document.getElementById('roleInput').value = role;

    document.getElementById('tabMember').classList.toggle('active', role === 'member');
    document.getElementById('tabAdmin').classList.toggle('active',  role === 'admin');

    // 관리자 탭에서는 회원가입 링크 숨김
    const signupLink = document.getElementById('signupLink');
    if (signupLink) signupLink.classList.toggle('hidden', role === 'admin');
}

document.addEventListener('DOMContentLoaded', () => {

    /* ── 비밀번호 표시/숨기기 ── */
    document.getElementById('togglePw').addEventListener('click', () => {
        const pwInput = document.getElementById('password');
        const eyeIcon = document.getElementById('eyeIcon');
        const isHidden = pwInput.type === 'password';

        pwInput.type = isHidden ? 'text' : 'password';
        // Lucide 아이콘 전환 후 재초기화
        eyeIcon.setAttribute('data-lucide', isHidden ? 'eye-off' : 'eye');
        if (window.lucide) lucide.createIcons();
    });

    /* ── 폼 제출 유효성 검증 ── */
    // novalidate 선언된 폼이므로 JS에서 직접 검증
    document.getElementById('loginForm').addEventListener('submit', (e) => {
        const id = document.getElementById('loginId').value.trim();
        const pw = document.getElementById('password').value.trim();
        let valid = true;

        const idError = document.getElementById('idError');
        if (!id) {
            idError.classList.remove('hidden');
            valid = false;
        } else {
            idError.classList.add('hidden');
        }

        const pwError = document.getElementById('pwError');
        if (!pw) {
            pwError.classList.remove('hidden');
            valid = false;
        } else {
            pwError.classList.add('hidden');
        }

        if (!valid) e.preventDefault();
    });
});
