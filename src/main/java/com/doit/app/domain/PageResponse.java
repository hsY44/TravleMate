package com.doit.app.domain;

import java.util.List;

import com.doit.app.common.PaginateUtil;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PageResponse<T, V> {

    private PaginateUtil page;
    private List<V> data;

    public PageResponse(PaginateUtil pageInfo, List<V> data) {
        this.page = pageInfo;
        this.data = data;
    }
}