---
name: code-review
description: |
  **AI 코드 리뷰**: 최근 변경된 코드를 분석하여 버그, 보안, 성능, 구조 이슈를 리뷰합니다.
  - MANDATORY TRIGGERS: 코드 리뷰, code review, 리뷰 해줘, PR 리뷰, 코드 검수, 코드 점검
  git diff 기반으로 변경된 파일을 자동 감지하고 일관된 기준으로 리뷰합니다.
---

# AI 코드 리뷰 스킬

변경된 코드를 일관된 기준으로 리뷰하는 스킬입니다.
updated: 2026-03-06

## 전체 흐름

```
1. 리뷰 대상 파일 감지 (git diff)
2. 변경된 파일 전체 읽기
3. 리뷰 기준에 따라 분석
4. 결과를 정해진 포맷으로 출력
```

---

## 1단계: 리뷰 대상 감지

### 대상 결정 우선순위

1. 사용자가 파일/경로를 지정한 경우 → 해당 파일만
2. "최근 커밋" / "마지막 작업" 등 → `git diff HEAD~N..HEAD` (N은 사용자 지정, 기본 1)
3. "PR 리뷰" → `git diff main...HEAD`
4. 아무 지정 없으면 → `git diff HEAD~1..HEAD` (마지막 커밋)

### 대상 파일 필터링

리뷰 대상에서 **제외**하는 파일:
- `pnpm-lock.yaml`, `package-lock.json`, `yarn.lock`
- `.husky/*`, `.github/*` (워크플로우 제외)
- 이미지, 폰트 등 바이너리 파일
- `*.config.js`, `*.config.ts` (설정 파일은 명시 요청 시에만)

리뷰 대상에 **포함**하는 파일:
- `.ts`, `.tsx`, `.js`, `.jsx` — 주요 리뷰 대상
- `.css`, `.scss` — 스타일 변경
- API 함수 파일 (`src/lib/api/**`)

---

## 2단계: 리뷰 기준

### 기준 A: 버그 / 런타임 에러 (심각도: HIGH)

- React hooks 규칙 위반 (조건부 호출, deps 배열 오류, stale closure)
- `useCallback` / `useMemo` deps가 실제 참조와 불일치
- controlled vs uncontrolled 컴포넌트 혼용 (`value` vs `defaultValue`)
- null/undefined 접근 가능성 (optional chaining 누락)
- 비동기 처리 오류 (race condition, cleanup 누락)
- 타입 단언(`as`)으로 인한 런타임 불일치

### 기준 B: 보안 취약점 (심각도: HIGH)

- XSS: 외부 데이터가 `href`, `innerHTML`, `dangerouslySetInnerHTML`에 직접 사용
- `javascript:`, `data:` 프로토콜 미검증
- 민감 정보 노출 (API 키, 토큰이 클라이언트 코드에 하드코딩)
- postMessage origin 미검증
- API 요청 시 인증 토큰 누락 가능성

### 기준 C: 성능 (심각도: MEDIUM)

- 불필요한 리렌더링 유발 (매 렌더마다 새 객체/배열/함수 생성)
- `useEffect` 무한 루프 가능성
- 대용량 리스트 최적화 누락 (가상화, 페이지네이션)
- 이미지 최적화 누락 (`next/image` 미사용)

### 기준 D: Dead Code / 논리 오류 (심각도: MEDIUM)

- 도달 불가능한 코드
- 중복 실행되는 로직 (이미 처리된 조건 재검사)
- 사용되지 않는 import, 변수, 함수
- 불필요한 조건 분기 (항상 true/false)

### 기준 E: 구조 / 유지보수성 (심각도: LOW)

- 단일 파일 과다 (300줄+ 또는 컴포넌트 3개+)
- 반복되는 패턴이 추상화 없이 복붙
- 관심사 미분리 (UI + 비즈니스 로직 + API 호출 혼재)
- 네이밍 불일치 (snake_case / camelCase 혼용 등)

---

## 3단계: 프로젝트 컨텍스트

이 프로젝트(opndoctor-web)에 특화된 체크:

### 기술 스택 규칙
- Next.js App Router 사용 → `"use client"` 지시어 확인
- Zustand 스토어 → selector 패턴 사용 여부
- React Query → `queryKey` 일관성, 에러/로딩 처리
- Radix UI → 접근성 컴포넌트 활용 여부
- Tailwind CSS → 매직넘버 대신 디자인 토큰 사용

### 아키텍처 규칙 (FSD 기반)
- `entities/` — 도메인 모델, hooks
- `features/` — 비즈니스 기능
- `shared/` — 공통 유틸, UI
- `lib/api/` — API 함수
- 레이어 간 의존성 방향 확인 (상위 → 하위만 허용)

### iframe 통신 규칙
- `postMessage` origin 검증 필수
- `IframeMessageType` enum 사용 여부
- Flutter ↔ Next.js 메시지 포맷 일관성

---

## 4단계: 출력 포맷

### 리뷰 결과 형식

```
# 코드 리뷰 결과

**대상**: (커밋 범위 또는 파일 목록)
**변경 파일 수**: N개
**변경 라인 수**: +N / -N

---

## 발견 사항

### HIGH (반드시 수정)

#### 1. [제목]
**파일**: `파일경로:라인번호`
**기준**: (A: 버그 / B: 보안)

현재 코드:
(코드 블록)

문제:
(문제 설명)

제안:
(수정 방향 또는 코드)

---

### MEDIUM (수정 권장)

(같은 형식)

---

### LOW (개선 제안)

(같은 형식)

---

## 잘한 점

- (긍정적 피드백 2-3개)

## 요약

| 심각도 | 건수 | 항목 |
|--------|------|------|
| HIGH   | N    | 간략 설명 |
| MEDIUM | N    | 간략 설명 |
| LOW    | N    | 간략 설명 |
```

### 출력 규칙

- 발견 사항이 없는 심각도는 생략
- 잘한 점은 반드시 2개 이상 포함 (긍정적 피드백)
- 요약 테이블은 항상 포함
- 파일 경로는 `파일경로:라인번호` 형식으로 표기
- 코드 블록은 해당 언어로 syntax highlight

---

## 사용 예시

### 기본 (마지막 커밋 리뷰)
```
코드 리뷰 해줘
```

### 최근 N개 커밋
```
최근 5개 커밋 코드 리뷰 해줘
```

### PR 단위 리뷰
```
PR 리뷰 해줘 (main 대비)
```

### 특정 파일
```
HospitalTabSection.tsx 리뷰 해줘
```
