/* ═══════════════════════════════════════════
   planDetail.js
   - planDetail.jsp 에서 사용하는 스크립트
   - ctx, planId, isHost, canEdit, inviteCode,
     planStartDate, costLabels, costData 는 JSP 에서 인라인으로 주입
═══════════════════════════════════════════ */

/* ── 탭 전환 ── */
function switchDetailTab(tab) {
    const tabs = { schedule: 'tabSchedule', cost: 'tabCost', guests: 'tabGuests', history: 'tabHistory' };
    Object.values(tabs).forEach(id => {
        const el = document.getElementById(id);
        if (el) el.classList.add('hidden');
    });
    const target = document.getElementById(tabs[tab]);
    if (target) target.classList.remove('hidden');

    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
    const activeBtn = document.getElementById('tabBtn-' + tab);
    if (activeBtn) activeBtn.classList.add('active');

    if (tab === 'cost') { renderCostChart(); }
}

/* ── 비용 도넛 차트 ── */
let _costChart = null;
function renderCostChart() {
    const canvas = document.getElementById('costChart');
    if (!canvas || !costLabels || !costLabels.length) { return; }
    if (_costChart) { return; }

    _costChart = new Chart(canvas, {
        type: 'doughnut',
        data: {
            labels: costLabels,
            datasets: [{ data: costData, borderWidth: 0 }]
        },
        options: {
            plugins: { legend: { position: 'bottom' } },
            cutout: '65%'
        }
    });
}

/* ── 날짜 변환 헬퍼 ── */
// dayIndex(0-based) → 'yyyy-MM-dd'
function indexToDate(index) {
    const d = new Date(planStartDate);
    d.setDate(d.getDate() + index);
    return d.toISOString().slice(0, 10);
}

// 'yyyy-MM-dd' → dayIndex (planStartDate 기준)
function dateToIndex(dateStr) {
    const start = new Date(planStartDate);
    const target = new Date(dateStr);
    return Math.round((target - start) / 86400000);
}

/* ── 초대 코드 복사 ── */
function copyInviteCode() {
    if (!inviteCode) { return; }
    navigator.clipboard.writeText(inviteCode)
        .then(() => showToast('초대 코드가 복사되었습니다.'))
        .catch(() => showToast('복사에 실패했습니다.', 2000, 'error'));
}

/* ── 컨텐츠 검색 ── */
let _contentSearchTimer = null;

const _CONTENT_TYPE_COST_MAP = {
    '32': '숙박',
    '39': '식비',
    '38': '쇼핑'
};

function triggerContentSearch() {
    const kwd = document.getElementById('schedContentSearch').value;
    searchContent(kwd);
}

function searchContent(kwd) {
    clearTimeout(_contentSearchTimer);
    const results  = document.getElementById('contentSearchResults');
    const category = document.getElementById('schedContentCategory')?.value || 'all';
    const addr     = document.getElementById('schedContentAddr')?.value     || '';

    if (!kwd.trim() && category === 'all' && !addr.trim()) {
        results.classList.add('hidden');
        return;
    }
    _contentSearchTimer = setTimeout(async () => {
        try {
            const url  = ctx + '/contents/search'
                       + '?kwd='      + encodeURIComponent(kwd)
                       + '&category=' + encodeURIComponent(category)
                       + '&addr='     + encodeURIComponent(addr);
            const list = await fetchJSON(url);
            if (!list.length) {
                results.innerHTML = '<p class="px-3 py-2 text-xs text-slate-400">검색 결과가 없습니다.</p>';
            } else {
                results.innerHTML = list.map(c => {
                    const safeTitle = (c.title || '').replace(/'/g, '&#39;');
                    const safeImg   = (c.firstImage || '').replace(/'/g, '&#39;');
                    const typeId    = c.contentTypeId || '';
                    const thumb     = c.firstImage
                        ? `<img src="${c.firstImage}" class="h-9 w-9 flex-shrink-0 rounded-lg object-cover bg-slate-100">`
                        : `<div class="h-9 w-9 flex-shrink-0 rounded-lg bg-slate-100 flex items-center justify-center text-slate-300"><svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg></div>`;
                    const divBadge  = c.contentDiv
                        ? `<span class="text-xs text-sky-500 font-medium">${c.contentDiv}</span>`
                        : '';
                    return `<button type="button"
                                 onclick="selectContent(${c.contentId}, '${safeTitle}', '${safeImg}', '${typeId}')"
                                 class="w-full flex items-center gap-2.5 px-3 py-2 text-left hover:bg-slate-50 border-b border-slate-50 last:border-0">
                                ${thumb}
                                <div class="min-w-0">
                                    <p class="text-sm font-semibold text-slate-900 truncate">${c.title}</p>
                                    <div class="flex items-center gap-1.5">
                                        ${divBadge}
                                        ${c.addr1 ? `<p class="text-xs text-slate-400 truncate">${c.addr1}</p>` : ''}
                                    </div>
                                </div>
                            </button>`;
                }).join('');
            }
            results.classList.remove('hidden');
        } catch (e) {
            results.classList.add('hidden');
        }
    }, 300);
}

function selectContent(id, name, image, contentTypeId) {
    document.getElementById('schedContentNo').value    = id;
    document.getElementById('schedContentImage').value = image || '';
    document.getElementById('schedContentSearch').value = '';
    document.getElementById('contentSearchResults').classList.add('hidden');
    document.getElementById('schedContentSelectedName').textContent = name;

    const img     = document.getElementById('schedContentPreviewImg');
    const preview = document.getElementById('schedContentPreview');
    if (image) {
        img.src = image;
        img.classList.remove('hidden');
    } else {
        img.src = '';
        img.classList.add('hidden');
    }
    preview.classList.remove('hidden');
    preview.classList.add('flex');
    if (typeof lucide !== 'undefined') lucide.createIcons();

    // 검색 결과에서 선택 시 비용 카테고리 자동 설정
    if (contentTypeId) {
        const costCat = _CONTENT_TYPE_COST_MAP[String(contentTypeId)] || '관광/체험';
        document.getElementById('schedCostCat').value = costCat;
    }
}

function clearContentSelection() {
    document.getElementById('schedContentNo').value    = '';
    document.getElementById('schedContentImage').value = '';
    document.getElementById('schedContentSearch').value = '';
    document.getElementById('contentSearchResults').classList.add('hidden');
    const preview = document.getElementById('schedContentPreview');
    preview.classList.add('hidden');
    preview.classList.remove('flex');
    document.getElementById('schedContentPreviewImg').src = '';
}

/* ── 일정 수정 모달 열기 ── */
function openEditSchedule(id) {
    fetchJSON(ctx + '/plans/' + planId + '/itinerary/' + id)
        .then(sc => {
            document.getElementById('scheduleModalTitle').textContent = '일정 수정';
            document.getElementById('editScheduleId').value    = sc.id;
            document.getElementById('schedDay').value          = dateToIndex(sc.itineraryDt);
            document.getElementById('schedTime').value         = sc.time         || '';
            document.getElementById('schedTitle').value        = sc.title        || '';
            document.getElementById('schedContent').value      = sc.content      || '';
            document.getElementById('schedCost').value         = sc.cost         || 0;
            document.getElementById('schedCostCat').value      = sc.costCategory || '기타';
            clearContentSelection();
            if (sc.contentNo) {
                selectContent(sc.contentNo, sc.contentName || '', sc.contentImage || '');
            }
            openModal('addScheduleModal');
        })
        .catch(() => showToast('일정을 불러오지 못했습니다.', 2000, 'error'));
}

// 추가 버튼 클릭 시 모달 초기화
function resetScheduleModal() {
    document.getElementById('scheduleModalTitle').textContent = '일정 추가';
    document.getElementById('editScheduleId').value = '';
    document.getElementById('schedDay').value        = '0';
    document.getElementById('schedTime').value       = '';
    document.getElementById('schedTitle').value      = '';
    document.getElementById('schedContent').value    = '';
    document.getElementById('schedCost').value       = '';
    document.getElementById('schedCostCat').value    = '기타';
    const catEl  = document.getElementById('schedContentCategory');
    const addrEl = document.getElementById('schedContentAddr');
    if (catEl)  catEl.value  = 'all';
    if (addrEl) addrEl.value = '';
    clearContentSelection();
}

/* ── 일정 저장 (추가/수정) ── */
async function saveSchedule() {
    const editId       = document.getElementById('editScheduleId').value;
    const dayIdx       = parseInt(document.getElementById('schedDay').value, 10);
    const time         = document.getElementById('schedTime').value;
    const title        = document.getElementById('schedTitle').value.trim();
    const content      = document.getElementById('schedContent').value.trim();
    const cost         = parseInt(document.getElementById('schedCost').value, 10) || 0;
    const costCategory = document.getElementById('schedCostCat').value;
    const contentNoRaw = document.getElementById('schedContentNo').value;
    const contentNo    = contentNoRaw ? parseInt(contentNoRaw, 10) : null;

    if (!title) { showToast('제목을 입력하세요.', 2000, 'error'); return; }

    const itineraryDt = indexToDate(dayIdx);
    const url    = editId
        ? ctx + '/plans/' + planId + '/itinerary/' + editId
        : ctx + '/plans/' + planId + '/itinerary';
    const method = editId ? 'PUT' : 'POST';

    try {
        await fetchJSON(url, {
            method,
            body: JSON.stringify({ itineraryDt, time, title, content, contentNo, cost, costCategory })
        });
        closeModal('addScheduleModal');
        location.reload();
    } catch (e) {
        const msg = (e.message && !e.message.startsWith('{') && !e.message.startsWith('<'))
            ? e.message
            : '저장에 실패했습니다. 잠시 후 다시 시도해주세요.';
        showToast(msg, 3000, 'error');
    }
}

/* ── 일정 삭제 ── */
function deleteSchedule(id) {
    openConfirm('이 일정을 삭제하시겠습니까?', async () => {
        try {
            await fetchJSON(ctx + '/plans/' + planId + '/itinerary/' + id, { method: 'DELETE' });
            location.reload();
        } catch (e) {
            showToast(e.message || '삭제에 실패했습니다.', 2000, 'error');
        }
    }, true);
}

/* ── 계획 나가기 (게스트 본인) ── */
function leavePlan() {
    openConfirm('이 여행 계획에서 나가시겠습니까?\n당신의 일정 입력 내역은 유지됩니다.', async () => {
        try {
            await fetchJSON(ctx + '/plans/' + planId + '/leave', { method: 'DELETE' });
            location.href = ctx + '/plans';
        } catch (e) {
            showToast(e.message || '나가기에 실패했습니다.', 2000, 'error');
        }
    }, true);
}

/* ── 계획 삭제 ── */
function deletePlan() {
    openConfirm('여행 계획을 삭제하면 모든 일정과 이력이 삭제됩니다. 계속하시겠습니까?', async () => {
        try {
            await fetchJSON(ctx + '/plans/' + planId, { method: 'DELETE' });
            location.href = ctx + '/plans';
        } catch (e) {
            showToast(e.message || '삭제에 실패했습니다.', 2000, 'error');
        }
    }, true);
}

/* ── 계획 수정 저장 ── */
async function savePlanEdit() {
    const title     = document.getElementById('editPlanTitle').value.trim();
    const theme     = document.getElementById('editPlanTheme').value.trim();
    const startDate = document.getElementById('editPlanStart').value;
    const endDate   = document.getElementById('editPlanEnd').value;
    const overview  = document.getElementById('editPlanOverview').value.trim();

    if (!title || !startDate || !endDate) {
        showToast('제목과 날짜는 필수입니다.', 2000, 'error');
        return;
    }

    try {
        await fetchJSON(ctx + '/plans/' + planId, {
            method: 'PUT',
            body: JSON.stringify({ title, theme, startDate, endDate, overview })
        });
        closeModal('editPlanModal');
        location.reload();
    } catch (e) {
        showToast(e.message || '수정에 실패했습니다.', 2000, 'error');
    }
}

/* ── 게스트 내보내기 ── */
function kickGuest(memberId, nickname) {
    openConfirm(nickname + ' 님을 여행에서 내보내시겠습니까?', async () => {
        try {
            await fetchJSON(ctx + '/plans/' + planId + '/guest/' + memberId, { method: 'DELETE' });
            location.reload();
        } catch (e) {
            showToast(e.message || '내보내기에 실패했습니다.', 2000, 'error');
        }
    }, true);
}

/* ── 호스트 위임 ── */
function transferHost(memberId, nickname) {
    openConfirm(nickname + ' 님에게 호스트를 위임하시겠습니까?\n위임 후 당신은 일반 게스트가 됩니다.', async () => {
        try {
            closeModal('transferHostModal');
            await fetchJSON(ctx + '/plans/' + planId + '/host', {
                method: 'PUT',
                body: JSON.stringify({ newHostMemberNo: memberId })
            });
            showToast('호스트가 위임되었습니다.');
            location.reload();
        } catch (e) {
            showToast(e.message || '위임에 실패했습니다.', 2000, 'error');
        }
    }, true);
}

/* ── 게스트 편집 권한 토글 ── */
async function togglePermission(memberId, currentCanEdit) {
    try {
        await fetchJSON(ctx + '/plans/' + planId + '/guest/' + memberId + '/permission', {
            method: 'PUT',
            body: JSON.stringify({ canEdit: currentCanEdit ? 0 : 1 })
        });
        location.reload();
    } catch (e) {
        showToast(e.message || '권한 변경에 실패했습니다.', 2000, 'error');
    }
}

/* ── 초대코드 재생성 ── */
async function regenerateInviteCode() {
    openConfirm('초대 코드를 재생성하시겠습니까?\n기존 코드는 더 이상 사용할 수 없습니다.', async () => {
        try {
            const res = await fetchJSON(ctx + '/plans/' + planId + '/invite', { method: 'POST' });
            document.getElementById('inviteCodeDisplay').textContent = res.inviteCode;
            inviteCode = res.inviteCode;
            showToast('새 초대 코드가 생성되었습니다.');
        } catch (e) {
            showToast(e.message || '재생성에 실패했습니다.', 2000, 'error');
        }
    }, true);
}

/* ── 초기화 ── */
document.addEventListener('DOMContentLoaded', () => {
    // 일정 추가 버튼: 모달 열기 전 폼 초기화
    const addBtn = document.querySelector('[onclick="openModal(\'addScheduleModal\')"]');
    if (addBtn) {
        addBtn.addEventListener('click', resetScheduleModal);
    }

    // 컨텐츠 검색 드롭다운: 외부 클릭 시 닫기
    document.addEventListener('click', e => {
        const search  = document.getElementById('schedContentSearch');
        const results = document.getElementById('contentSearchResults');
        if (results && search && !search.contains(e.target) && !results.contains(e.target)) {
            results.classList.add('hidden');
        }
    });

});
