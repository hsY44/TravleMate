package com.doit.app.domain;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ContentImageVO {

    private Long contentImageId;
    private String originImgUrl;
    private String imgName;
}