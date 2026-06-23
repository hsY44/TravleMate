package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SanctionVo {
    private Long   sanctionNo;
    private Long   memberNo;
    private int    levelDays;   // 제재 일수 (1 / 3 / 7)
    private String reason;
    private String comment;
    private Long   adminNo;
}
