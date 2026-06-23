/*===============================================
    PaginateUtil.java
    - 페이징 계산 유틸리티
    - Controller 에서 생성 후 Mapper 에 startRow/endRow 전달
    - JSP 에서 pageInfo 로 페이지 버튼 렌더링
===============================================*/
package com.doit.app.common;

import lombok.Getter;

@Getter
public class PaginateUtil
{
    private final int page;        // 현재 페이지 (1부터 시작)
    private final int pageSize;    // 페이지 당 행 수
    private final int startRow;    // Oracle ROWNUM 하한 (inclusive)
    private final int endRow;      // Oracle ROWNUM 상한 (inclusive)
    private int totalCount;        // 전체 건수 (setTotalCount 호출 후 사용)
    private int totalPages;        // 전체 페이지 수

    // 현재 페이지 블록의 시작/끝 페이지 (버튼 렌더링용)
    private int blockStart;
    private int blockEnd;

    private static final int BLOCK_SIZE = 10; // 페이지 버튼 묶음 크기

    public PaginateUtil(int page, int pageSize)
    {
        this.page     = Math.max(page, 1);
        this.pageSize = pageSize;
        this.startRow = (this.page - 1) * pageSize + 1;
        this.endRow   = this.page * pageSize;
    }

    // totalCount 를 받아 나머지 값 계산
    // Mapper 에서 COUNT 결과를 받은 뒤 반드시 호출
    public void setTotalCount(int totalCount)
    {
        this.totalCount  = totalCount;
        this.totalPages  = (totalCount + pageSize - 1) / pageSize;
        this.blockStart  = ((page - 1) / BLOCK_SIZE) * BLOCK_SIZE + 1;
        this.blockEnd    = Math.min(blockStart + BLOCK_SIZE - 1, totalPages);
    }

    public boolean hasPrev() { return blockStart > 1; }
    public boolean hasNext() { return blockEnd < totalPages; }
}
