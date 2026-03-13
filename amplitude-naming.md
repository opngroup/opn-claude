---
name: amplitude-naming
description: |
  **앰플리튜드 이벤트 네이밍 생성기**: 기능 설명을 입력하면 오픈닥터 네이밍 규칙에 맞는 이벤트명과 프로퍼티를 제안하고, 확인 후 노션 문서에 자동 기록합니다.
  - MANDATORY TRIGGERS: 앰플리튜드, amplitude, 이벤트 네이밍, 이벤트명, event naming, 트래킹 이벤트, 이벤트 설계, 프로퍼티 설계
  기능 설명이나 화면/행동을 알려주면 이벤트명과 프로퍼티를 생성합니다.
---

# Amplitude 이벤트 네이밍 생성기

오픈닥터의 앰플리튜드 이벤트명과 프로퍼티를 네이밍 규칙에 맞게 생성하는 스킬입니다.
사용자가 기능이나 화면을 설명하면 이벤트명+프로퍼티를 제안하고, 확인 후 노션에 기록합니다.
updated : 2026-02-23 (문서 갱신시 업데이트할것)

## 전체 흐름

```
1. 노션에서 기존 이벤트 목록 조회 (중복/일관성 체크)
2. 사용자 설명 기반으로 이벤트명 + 프로퍼티 제안
3. 사용자 확인 및 피드백 반영
4. 확정된 이벤트를 노션 문서에 기록
```

---

## 1단계: 기존 이벤트 조회

스킬 실행 시 가장 먼저 노션 문서를 조회합니다.

### 노션 문서 정보

- **페이지 ID**: `1dd62aded33680f69a5dc023286a9741`
- **URL**: https://www.notion.so/opndoctor/1dd62aded33680f69a5dc023286a9741

Notion fetch 도구로 이 페이지를 조회해서 기존 이벤트 목록을 가져옵니다.
이 목록은 이후 단계에서 다음 용도로 사용됩니다:

- **중복 체크**: 이미 동일/유사한 이벤트가 있는지 확인
- **네이밍 일관성**: 기존 패턴과 어긋나지 않는지 확인
- **프로퍼티 재사용**: 이미 정의된 프로퍼티명이 있으면 동일하게 사용

---

## 2단계: 이벤트명 + 프로퍼티 제안

### 네이밍 규칙

이 규칙을 **반드시** 따릅니다:

#### 이벤트명

| 항목 | 규칙 |
|------|------|
| 형식 | `[Object] [Past Tense Verb]` |
| 대소문자 | Title Case |
| 동사 시제 | 과거형 (Clicked, Viewed, Opened 등) |
| 전체화면 | `Screen` 사용 |
| 모달창 | `Modal` 사용 |
| 탭 진입 | `Tab Viewed` 사용 |
| 상세페이지 | `Detail Viewed` 사용 |
| 완료 전 단계 | `Submitted`/`Requested` 대신 `Clicked` 또는 `Modal Opened` |
| 최종 제출 | `Requested` 사용 |
| 단계 추적 | `Step Tracked` 사용 |

#### 프로퍼티

| 항목 | 규칙 |
|------|------|
| 표기법 | `snake_case` |
| 문자열 | `user_type`, `from_page`, `utm_source` 등 |
| 숫자 | `price`, `duration_sec`, `budget_range` 등 |
| 불리언 | `is_` 접두어 (`is_repeat_user`, `has_image`) |
| ID/참조값 | `_id` 접미어 (`report_id`) |
| 날짜/시간 | `_at`, `_date` 접미어 (`signup_at`) |

#### 핵심 원칙

- 동일 행동은 이벤트명 통일, **분기 조건은 프로퍼티로 표현**
- 퍼널 설계 고려: `Clicked` → `Modal Opened` → `Step Tracked` → `Requested` 흐름
- 유입 분석용 프로퍼티: `from_page`, `content_type`, `entry_point` 적극 활용
- 기존에 정의된 프로퍼티명이 있으면 새로 만들지 않고 **재사용**

### 자주 쓰는 프로퍼티 (기존 문서 기준)

| 프로퍼티명 | 설명 | 값 예시 |
|-----------|------|---------|
| `from_page` | 유입 페이지 | Home, Analysis, Hospital, Property, analysis_detail, property_detail, hospital_detail |
| `resource_type` | 리소스 유형 | consultation, property, radius, region, polygon |
| `content_type` | 콘텐츠 유형 | location, address, Property, Hospital |
| `provider` | 인증 제공자 | google, email, kakao, apple |
| `platform` | 플랫폼 | web, app |
| `trigger_type` | 트리거 유형 | banner, button |
| `step_name` | 단계명 | start, step1, step2, step3, check |

### 제안 형식

사용자에게 다음 형식으로 제안합니다:

```
📋 이벤트 제안

1. `Event Name Here`
   - 위치: (어떤 화면/행동인지)
   - 플랫폼: 웹, 앱
   - 프로퍼티:
     - property_name: 설명 (값 예시)
     - property_name: 설명 (값 예시)

2. `Another Event Name`
   ...
```

기존 이벤트와 중복되거나 유사한 것이 있으면 명시적으로 알려줍니다:

```
⚠️ 기존에 유사한 이벤트가 있습니다:
   - `Consult Start Clicked` — 현재 상담신청 시작 클릭에 사용 중
   → 새 이벤트 대신 기존 이벤트의 프로퍼티를 확장하는 것을 권장합니다.
```

### 복수 이벤트 제안

사용자가 여러 기능을 한번에 설명할 수 있습니다. 이 경우:

- 관련된 이벤트들을 그룹으로 묶어서 제안
- 퍼널 순서가 있다면 순서대로 나열
- 이벤트 간 공통 프로퍼티가 있으면 명시

---

## 3단계: 사용자 확인

제안 후 사용자에게 확인합니다:

```
이 이벤트명으로 확정할까요?
수정할 부분이 있으면 알려주세요.

확정되면 노션 문서에 기록할게요.
```

사용자가 수정을 요청하면 반영 후 다시 제안합니다.
"ㅇㅇ", "좋아", "확정" 같은 간결한 답변도 확인으로 인식하세요.

---

## 4단계: 노션 문서에 기록

확정된 이벤트를 노션 문서의 테이블에 추가합니다.

### 노션 문서 구조

페이지 ID: `1dd62aded33680f69a5dc023286a9741`

메인 테이블의 컬럼:
| 플랫폼 | 위치 | 이벤트 명 | property | 등록일(수정일) |

### 기록 방법

Notion update-page 도구의 `insert_content_after` 커맨드를 사용합니다.

기존 테이블의 마지막 행(빈 행) 앞에 새 행을 추가합니다.

#### 기록 형식

각 이벤트마다 테이블 행으로 추가:

- **플랫폼**: 사용자가 지정한 값 (기본: "웹, 앱")
- **위치**: 사용자가 설명한 화면/행동 (한글)
- **이벤트 명**: 백틱으로 감싼 이벤트명 (`` `Event Name` ``)
- **property**: 각 프로퍼티를 `- property_name: 값 설명` 형식으로
- **등록일(수정일)**: 오늘 날짜 (YYYY-MM-DD)

### 기록 후

```
✅ 노션 문서에 기록했어요.
   - Event Name 1
   - Event Name 2

확인: https://www.notion.so/opndoctor/1dd62aded33680f69a5dc023286a9741
```

---

## 트러블슈팅

- **노션 문서에 접근 안 될 때**: 페이지 ID 확인, Notion MCP 연결 상태 확인
- **기존 이벤트와 네이밍이 충돌할 때**: 기존 이벤트를 우선하고 프로퍼티 확장을 권장
- **프로퍼티 값이 불명확할 때**: 사용자에게 구체적인 값 목록을 물어보기
- **여러 섹션에 걸친 이벤트일 때**: 해당 섹션(예: 중개사 상담신청 섹션)의 패턴을 따르기
