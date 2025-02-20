---
title: "모든 http 상태코드 알아보기"
date: 2024-06-05T09:38:59+09:00
tages: ["http", "status code"]
draft: false
---

## 1xx (Informational) : 요청이 수신되었으며 프로세스가 계속 진행 중

-   100 Continue : 서버가 요청의 일부를 받았으며 클라이언트가 요청을 계속해도 됨을 알림
-   101 Switching Protocols : 서버가 업그레이드 요청을 수락하고 프로토콜 변경을 알림
-   102 Processing : 서버가 요청을 수신하고 처리 중임
-   103 Early Hints : 서버가 일부 응답을 보냈으며 클라이언트가 요청을 계속해도 됨을 알림

## 2xx (Successful) : 요청이 성공적으로 수신되었으며 이해되었고 수락되었음

-   200 OK : 요청이 성공적으로 수신되었으며 이해되었음
-   201 Created : 요청이 성공적으로 수신되었으며 새로운 리소스가 생성되었음
-   202 Accepted : 요청이 수신되었으며 처리가 완료되지 않았음
-   203 Non-Authoritative Information : 요청이 성공적으로 수신되었으며 응답은 프록시에서 제공됨
-   204 No Content : 요청이 성공적으로 수신되었으며 응답에 컨텐츠가 없음
-   205 Reset Content : 요청이 성공적으로 수신되었으며 사용자 에이전트가 문서 뷰를 재설정해야 함
-   206 Partial Content : 요청이 성공적으로 수신되었으며 일부 응답이 전송됨
-   207 Multi-Status : 요청이 성공적으로 수신되었으며 여러 상태 코드가 반환됨
-   208 Already Reported : 요청이 성공적으로 수신되었으며 멀티-상태 응답이 반환됨
-   226 IM Used : 요청이 성공적으로 수신되었으며 인스턴스가 멀티 상태 응답을 반환함

## 3xx (Redirection) : 클라이언트는 추가 작업이 필요함

-   300 Multiple Choices : 요청이 여러 옵션을 가지고 있음
-   301 Moved Permanently : 요청한 리소스가 새로운 URL로 영구적으로 이동됨
-   302 Found : 요청한 리소스가 일시적으로 다른 URL로 이동됨
-   303 See Other : 요청한 리소스가 다른 URL로 이동됨
-   304 Not Modified : 요청한 리소스가 수정되지 않았음
-   305 Use Proxy : 요청한 리소스는 프록시를 사용해야 함
-   306 Switch Proxy : 요청한 리소스는 다른 프록시를 사용해야 함
-   307 Temporary Redirect : 요청한 리소스가 일시적으로 다른 URL로 이동됨
-   308 Permanent Redirect : 요청한 리소스가 새로운 URL로 영구적으로 이동됨

## 4xx (Client Error) : 클라이언트에 오류가 있음

-   400 Bad Request : 요청이 잘못되었음
-   401 Unauthorized : 인증이 필요함
-   402 Payment Required : 결제가 필요함
-   403 Forbidden : 요청이 거부됨
-   404 Not Found : 요청한 리소스가 없음
-   405 Method Not Allowed : 요청된 메소드가 허용되지 않음
-   406 Not Acceptable : 요청된 리소스가 클라이언트가 허용하지 않음
-   407 Proxy Authentication Required : 프록시 인증이 필요함
-   408 Request Timeout : 요청 시간이 초과됨
-   409 Conflict : 요청이 충돌함
-   410 Gone : 요청한 리소스가 더 이상 사용되지 않음
-   411 Length Required : Content-Length 헤더가 필요함
-   412 Precondition Failed : 요청 전제 조건이 실패함
-   413 Payload Too Large : 요청이 너무 큼
-   414 URI Too Long : URI가 너무 김
-   415 Unsupported Media Type : 지원하지 않는 미디어 타입
-   416 Range Not Satisfiable : 범위가 만족되지 않음
-   417 Expectation Failed : 요청이 실패함
-   418 I'm a teapot : 나는 주전자입니다
-   421 Misdirected Request : 잘못된 요청
-   422 Unprocessable Entity : 처리할 수 없는 엔티티
-   423 Locked : 잠김
-   424 Failed Dependency : 의존성 실패
-   425 Too Early : 너무 이른 요청
-   426 Upgrade Required : 업그레이드 필요
-   428 Precondition Required : 전제 조건 필요
-   429 Too Many Requests : 요청이 너무 많음
-   431 Request Header Fields Too Large : 요청 헤더 필드가 너무 큼
-   451 Unavailable For Legal Reasons : 법적 이유로 사용할 수 없음

## 5xx (Server Error) : 서버에 오류가 있음

-   500 Internal Server Error : 서버에 오류가 있음
-   501 Not Implemented : 요청이 구현되지 않음
-   502 Bad Gateway : 게이트웨이가 잘못됨
-   503 Service Unavailable : 서비스를 사용할 수 없음
-   504 Gateway Timeout : 게이트웨이 시간 초과
-   505 HTTP Version Not Supported : HTTP 버전이 지원되지 않음
-   506 Variant Also Negotiates : 변형도 협상함
-   507 Insufficient Storage : 저장 공간이 부족함
-   508 Loop Detected : 루프가 감지됨
-   510 Not Extended : 확장되지 않음
-   511 Network Authentication Required : 네트워크 인증이 필요함
-   599 Network Connect Timeout Error : 네트워크 연결 시간 초과 오류

## 참고

-   [https://developer.mozilla.org/ko/docs/Web/HTTP/Status](https://developer.mozilla.org/ko/docs/Web/HTTP/Status)

> 418 I'm a teapot : 이 상태 코드는 1998년 4월 1일에 IETF에 의해 정의되었으며, Hyper Text Coffee Pot Control Protocol (HTCPCP)의 확장으로서, 커피포트가 차 있는지 확인하는 데 사용됩니다. 이것은 농담이며 실제로 사용되지 않습니다.
