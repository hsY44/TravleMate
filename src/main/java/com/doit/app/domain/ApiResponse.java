package com.doit.app.domain;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ApiResponse<T> {
    private int resultCode;    // 200, 400, 500 등등
    private String message;    // 성공, 에러 메시지 등등
    private T data;            // 데이터

    // 생성자
    public ApiResponse(int resultCode, String message, T data) {
        this.resultCode = resultCode;
        this.message = message;
        this.data = data;
    }

    // 성공 시 static 메서드
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(200, "success", data);
    }

    // 실패 시 static 메서드
    public static <T> ApiResponse<T> fail(int code, String msg) {
        return new ApiResponse<>(code, msg, null);
    }
}