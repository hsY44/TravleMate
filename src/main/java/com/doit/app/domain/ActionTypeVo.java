/*===============================================
    ActionTypeVo.java
    - 편집종류 도메인 객체
    - ACTION_TYPE 테이블 매핑
===============================================*/
package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ActionTypeVo
{
    private String actionTypeCd;   // ACTION_TYPE.ACTION_TYPE_CD
    private String actionTypeNm;   // ACTION_TYPE.ACTION_TYPE_NM
}
