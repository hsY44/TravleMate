/* contentDetail.js — 컨텐츠 상세 페이지 */

// ctx, contentId 는 contentDetail.jsp 인라인 스크립트에서 주입

// ── 갤러리 ────────────────────────────────────────────────────────
function selectGalleryImage(index) {
    document.querySelectorAll('[id^="galleryImg"]').forEach((img, i) => {
        img.classList.toggle('opacity-0', i !== index);
    });
    document.querySelectorAll('.gallery-thumb').forEach((thumb, i) => {
        thumb.classList.toggle('active', i === index);
    });
}

// ── 즐겨찾기 토글 ─────────────────────────────────────────────────
async function toggleDetailFavorite() {
    const res = await fetch(`${ctx}/contents/${contentId}/bookmark`, { method: 'POST' });
    if (!res.ok) { if (res.status === 401) { location.href = ctx + '/login'; } return; }

    const { favorited } = await res.json();
    const btn  = document.getElementById('favBtn');
    const icon = btn.querySelector('[data-lucide="heart"]') || btn.querySelector('svg');

    btn.classList.toggle('favorited', favorited);

    if (icon) {
        icon.classList.toggle('fill-red-500', favorited);
        icon.classList.toggle('text-red-500', favorited);
    }
}

// ── 모달 ──────────────────────────────────────────────────────────
// closeModal: form reset 포함 (common.js closeModal 오버라이드)
function closeModal(id) {
    const modal = document.getElementById(id);
    if (!modal) return;
    modal.classList.add('hidden');

    // 모달 div 내부(하위)에서 form 태그를 찾아 reset 실행
    const form = modal.querySelector('form');
    if (form) {
        form.reset();
    }
}

// ── 유틸 ──────────────────────────────────────────────────────────
function escHtml(str) {
    if (!str) return '';
    return str.replace(/&/g, '&amp;')
              .replace(/</g, '&lt;')
              .replace(/>/g, '&gt;')
              .replace(/"/g, '&quot;');
}

// ── 리뷰 바인딩 ────────────────────────────────────────────────
function renderReviewList(response) {
    const container = document.getElementById("reviewListContainer");
    const section = document.getElementById("reviewSection");

    // 현재 로그인한 유저 번호
    const currentMemberNo = section ? Number(section.dataset.currentMemberNo) : null;

    // JSON에서 리뷰 추출
    const reviewList = response.data.data;

    // 리뷰 데이터가 없을 경우
    if (!reviewList || reviewList.length === 0) {
        container.innerHTML = `<p class="py-6 text-center text-sm text-slate-400">첫 번째 리뷰를 작성해보세요!</p>`;
        return;
    }

    let html = '<div class="flex flex-col divide-y divide-slate-100">';
    reviewList.forEach(r => {
        // 별점(Star)
        let starsHtml = '';
        for (let s = 1; s <= 5; s++) {
            const starClass = s <= r.rating ? 'fill-amber-400 text-amber-400' : 'text-slate-200';
            starsHtml += `<i data-lucide="star" class="h-3.5 w-3.5 ${starClass}"></i>`;
        }

        // 데이터 바인딩 및 기본값
        const nickname = r.nickname || '익명';
        const firstChar = escHtml(nickname.charAt(0));
        const createdAt = r.createDt || '';
        const content = r.reviewComment || '내용이 없는 리뷰입니다.';
        const reviewId = r.contentReviewNo || 0;
        const rating = r.rating || 0;

        // 수정/삭제 or 신고 버튼 분기 (현재 로그인한 회원 번호와 리뷰 작성자 번호 비교)
        let buttonsHtml = '';
        if (r.memberNo && r.memberNo === currentMemberNo) {
            buttonsHtml = `
                <button onclick="openEditReview(${reviewId})" class="hover:text-sky-500">수정</button>
                <button onclick="deleteReview(${reviewId})" class="hover:text-red-500">삭제</button>
            `;
        } else {
            buttonsHtml = `
                <button onclick="openReportModal(${reviewId}, ${currentMemberNo})" class="hover:text-orange-500">신고</button>
            `;
        }

        // 리뷰
        html += '<div class="py-4" id="review' + reviewId + '">' +
                    '<div class="mb-2 flex items-center justify-between">' +
                        '<div class="flex items-center gap-2">' +
                            '<div class="flex h-8 w-8 items-center justify-center rounded-full bg-sky-100 text-sm font-bold text-sky-600">' +
                                firstChar +
                            '</div>' +
                            '<div>' +
                                '<span class="text-sm font-semibold text-slate-900">' + escHtml(nickname) + '</span>' +
                                '<div class="flex items-center gap-0.5" data-star="' + rating + '">' +
                                    starsHtml +
                                '</div>' +
                            '</div>' +
                        '</div>' +
                        '<div class="flex items-center gap-2 text-xs text-slate-400">' +
                            '<span>' + createdAt + '</span>' +
                            buttonsHtml +
                        '</div>' +
                    '</div>' +
                    '<p class="text-sm text-slate-600">' + escHtml(content) + '</p>' +
                '</div>';
    });

    html += '</div>';

    container.innerHTML = html;

    // Lucide 아이콘 라이브러리 새로고침 (동적 생성된 i 태그 변환용)
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }

    // 리뷰 갯수 업데이트
    const totalCount = response.data && response.data.page ? response.data.page.totalCount : 0;
    document.querySelectorAll('.review-count').forEach(el => {
        el.textContent = `리뷰 ${totalCount}개`;
    });

    renderReviewPagination(response);
}

// 페이징 버튼을 동적으로 그리는 함수
function renderReviewPagination(response) {
    const container = document.getElementById("reviewPaginationContainer");

    // JSON에서 page 정보 추출
    const pageInfo = response.data && response.data.page;
    if (!pageInfo) return;

    const currentPage = pageInfo.page;      // 현재 페이지
    const blockStart = pageInfo.blockStart;  // 블록 시작 번호
    const blockEnd = pageInfo.blockEnd;      // 블록 끝 번호
    const totalPages = pageInfo.totalPages;  // 전체 페이지 수

    // 이전/다음 블록이 존재하는지 여부 계산
    const hasPrev = blockStart > 1;
    const hasNext = blockEnd < totalPages;

    let html = '<nav class="mt-6 flex items-center justify-center gap-1">';

    // 이전 블록 버튼 생성 (hasPrev가 true일 때만)
    if (hasPrev) {
        html += `
            <a href="javascript:void(0);" onclick="changeReviewPage(${blockStart - 1})"
               class="flex h-9 w-9 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-500 hover:bg-slate-50 transition">
               <i data-lucide="chevron-left" class="h-4 w-4"></i>
            </a>
        `;
    }

    // 페이지 번호 생성 (blockStart부터 blockEnd까지 반복 배열 만들기)
    const pagesArray = [];
    for (let p = blockStart; p <= blockEnd; p++) {
        pagesArray.push(p);
    }

    // 배열 돌면서 바인딩
    html += pagesArray.map(p => {
        const isActive = p === currentPage;
        const activeClass = isActive
            ? 'border-sky-500 bg-sky-500 text-white'
            : 'border-slate-200 bg-white text-slate-600 hover:bg-slate-50';
        return `
            <a href="javascript:void(0);" onclick="changeReviewPage(${p})"
               class="flex h-9 w-9 items-center justify-center rounded-xl border text-sm font-semibold transition ${activeClass}">
               ${p}
            </a>
        `;
    }).join('');

    // 다음 블록 버튼 생성 (hasNext가 true일 때만)
    if (hasNext) {
        html += `
            <a href="javascript:void(0);" onclick="changeReviewPage(${blockEnd + 1})"
               class="flex h-9 w-9 items-center justify-center rounded-xl border border-slate-200 bg-white text-slate-500 hover:bg-slate-50 transition">
               <i data-lucide="chevron-right" class="h-4 w-4"></i>
            </a>
        `;
    }

    html += '</nav>';
    container.innerHTML = html;

    // 동적 생성된 Lucide 아이콘 새로고침
    if (typeof lucide !== 'undefined') {
        lucide.createIcons();
    }
}

// 페이지 클릭 시 동작할 이벤트 함수
function changeReviewPage(pageNumber) {
    // 1) hidden input의 value 값을 클릭한 페이지 번호로 변경
    document.getElementById("currentReviewPage").value = pageNumber;

    // 2) 변경된 페이지 번호로 리뷰 목록 조회 다시 호출
    getReviewList(pageNumber);
}

// ── 리뷰 작성/수정 ────────────────────────────────────────────────
function openEditReview(id) {
    const row = document.getElementById('review' + id);
    const content = row.querySelector('p').textContent.trim();

    const starContainer = row.querySelector("[data-star]");
    const rating = starContainer.dataset.star;

    document.getElementById('editReviewId').value = id;
    document.getElementById('reviewContent').value = content;
    document.getElementById('reviewModalTitle').textContent = '리뷰 수정';

    const radioEl = document.querySelector(`input[name="rating"][value="${rating}"]`);
    if (radioEl) radioEl.checked = true;

    openModal('writeReviewModal');
}

async function saveReview() {
    const editId  = document.getElementById('editReviewId').value;
    const content = document.getElementById('reviewContent').value.trim();
    const ratingEl = document.querySelector('input[name="rating"]:checked');
    const currentReviewPage = document.getElementById("currentReviewPage").value;

    if (!content)    { showToast("내용을 작성해 주세요.", 1500, "info"); return; }
    if (!ratingEl)   { showToast("별점을 선택해 주세요.", 1500, "info"); return; }

    const body = { content, rating: ratingEl.value };

    if (editId) {
        // 수정
        const res = await fetch(`${ctx}/contents/review/${contentId}/edit/${editId}`, {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        });
        if (!res.ok) { showToast('수정에 실패했습니다.', 2000, 'error'); return; }
        closeModal('writeReviewModal');
        location.reload();
    } else {
        // 작성
        const res = await fetch(`${ctx}/contents/review/${contentId}/add`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        });
        if (!res.ok) { showToast('저장에 실패했습니다.', 2000, 'error'); return; }
        closeModal('writeReviewModal');
        location.reload();
    }
}

async function deleteReview(id) {
    openConfirm('리뷰를 삭제하시겠습니까?', async () => {
        const res = await fetch(`${ctx}/contents/review/${contentId}/delete/${id}`, { method: 'DELETE' });
        if (!res.ok) { showToast('삭제에 실패했습니다.', 2000, 'error'); return; }
        location.reload();
    }, true);
}

// ── 신고 ──────────────────────────────────────────────────────────
function openReportModal(reviewId, memberNo) {
    if (!memberNo) { loginToast(); return; }
    document.getElementById('reportReviewId').value = reviewId;
    openModal('reportModal');
}

async function submitReport() {
    const contentReviewNo = document.getElementById('reportReviewId').value;
    const reportTypeCd = document.getElementById('reportCategory').value;
    const reportComment  = document.getElementById('reportContent').value.trim();

    if (!reportComment) { showToast('신고 내용을 입력해주세요.', 2000, 'error'); return; }

    const body = { contentReviewNo, reportTypeCd, reportComment };

    const res = await fetch(`${ctx}/contents/review/addReport`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
    });
    if (!res.ok) { showToast('신고에 실패했습니다.', 2000, 'error'); return; }
    showToast("신고가 접수되었습니다.", 1500, "info");
    closeModal('reportModal');
    location.reload();
}

// ── 일정 담기 ─────────────────────────────────────────────────────
async function addToPlan(planId, contentNo, title) {
    // 선택한 일자
    const daySelect = document.getElementById("daySelect_" + planId);
    const itineraryDt = daySelect ? daySelect.value : "1";

    if (!planId) {
        showToast("여행 계획이 선택되지 않았습니다.", 1500, "info");
        return;
    }
    if (!contentId || !title) {
        showToast("콘텐츠 정보가 올바르지 않습니다.", 1500, "info");
        return;
    }

    const res = await fetch(`${ctx}/plans/`+planId+"/itinerary", {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ itineraryDt, contentNo, title })
    });
    if (res.ok) {
        closeModal('addToPlanModal');
        showToast('여행 일정에 추가되었습니다.');
    } else {
        showToast('추가에 실패했습니다.', 2000, 'error');
    }
}

// 회원 전용 기능 클릭 시
function loginToast() {
    showToast("로그인 후 이용 가능", 1500, "info");
}