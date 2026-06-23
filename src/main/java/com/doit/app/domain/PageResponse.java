package com.doit.app.domain;

import java.util.List;

import com.doit.app.common.PaginateUtil;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PageResponse<T, V> {

	/*
    private int totalPage;
    private int size;
    private long dataCount;
    private List<T> data;

    public PageResponse(int totalPage, int size, long dataCount, List<T> data) {
        this.totalPage = totalPage;
        this.size = size;
        this.dataCount = dataCount;
        this.data = data;
    }
    */
    private PaginateUtil page;
    private List<V> data;

    public PageResponse(PaginateUtil pageInfo, List<V> data) {
        this.page = pageInfo;
        this.data = data;
    }
}