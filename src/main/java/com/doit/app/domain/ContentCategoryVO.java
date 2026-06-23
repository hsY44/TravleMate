package com.doit.app.domain;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class ContentCategoryVO {

	private String contentTypeId;	// 컨텐츠 카테고리 ID
	private String contentDiv;		// 컨텐츠 카테고리명
	
}
