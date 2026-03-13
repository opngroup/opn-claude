# OpnDoctor Frontend - Clean FSD Architecture

> Feature Sliced Design (FSD) 아키텍처를 적용한 Next.js 프로젝트 가이드

## 핵심 철학

**FSD = 단방향 의존성 + 도메인 중심 구조**

상위 레이어는 하위 레이어만 import 가능. 동일 레이어 간 cross-import 금지.

---

## FSD Layer Dependencies (엄격한 단방향 의존성)

```
app (routes) → widgets → features → entities → shared
```

| Layer | 역할 | 포함 내용 |
|-------|------|-----------|
| **shared** | 재사용 기반 코드 | UI 컴포넌트, utils, libs, types, HTTP client |
| **entities** | 비즈니스 엔티티 (READ only) | 도메인 타입, React Query 조회 훅, DTO |
| **features** | 비즈니스 로직 (CUD + 상호작용) | Mutation 훅, Zustand 상태, 폼 로직 |
| **widgets** | 조합된 UI 블록 | 여러 entities/features를 결합한 복합 컴포넌트 |
| **app** | 라우트/페이지 | Next.js App Router pages, layouts |

### Entities vs Features 구분

| 구분 | Entities (READ) | Features (WRITE/INTERACT) |
|------|-----------------|---------------------------|
| **역할** | 불변 데이터 제공 (ViewModel, DTO) | 사용자 상호작용으로 상태 변경 |
| **React Query** | `useQuery` 훅 (get*, fetch*) | `useMutation` 훅 (post*, patch*, delete*) |
| **Zustand** | 사용 안함 | 도메인별 클라이언트 상태 관리 |
| **규칙** | 순수 조회, 캐시 친화적 | entities를 읽을 수 있지만, 역방향 불가 |

### 의존성 흐름

```
[Pages / Widgets]
      ↓ (READ)
  [Entities]  ←─(READ)─  [Features]  ←─ 사용자 액션
```

---

## Technology Stack

- **Framework**: Next.js 14+ (App Router)
- **Language**: TypeScript (strict)
- **Server State**: React Query v5 (`@tanstack/react-query`)
- **Client State**: Zustand v5 (immer + persist + devtools)
- **HTTP Client**: Custom fetch 기반 (`app/apis/(http-client)`)
- **UI**: Tailwind CSS v4 + shadcn/ui (Radix primitives)
- **Validation**: Zod
- **Monitoring**: Sentry
- **Testing**: Jest + React Testing Library

---

## Directory Structure

```
app/                          ← FSD app layer (라우트)
  (auth)/                     ← 인증 가드
  {feature}/                  ← 페이지 + 레이아웃
    (components)/             ← 페이지 전용 컴포넌트 (widgets 역할)
    (helpers)/               ← 도메인 전용 유틸리티 함수
    page.tsx
    layout.tsx

app/apis/                     ← FSD entities + features layer (API)
  (http-client)/              ← shared: HTTP 클라이언트
  {domain}/
    get*.ts                   ← entities: 조회 API 함수
    post*.ts, patch*.ts, delete*.ts  ← features: 변경 API 함수
    *.dto.ts                  ← entities: 타입 정의 (API 함수와 분리)
    *.helpers.ts              ← entities: 도메인 타입 기반 순수 판별/변환 함수
    index.ts                  ← barrel export (public API 진입점)

app/stores/                   ← FSD features layer (클라이언트 상태)
  {domain}/
    {domain}Slice.ts          ← Zustand 슬라이스
    use{Domain}Actions.tsx    ← 상태 업데이트 훅
    index.ts                  ← barrel export

app/hooks/                    ← FSD shared/features layer (커스텀 훅)
app/utils/                    ← FSD shared layer (유틸리티)

components/                   ← FSD shared layer (공유 UI)
  ui/                         ← shadcn/ui 기본 컴포넌트
  *.tsx                       ← 공통 컴포넌트

features/                     ← FSD features layer (신규 마이그레이션)
lib/                          ← FSD shared layer (헬퍼)
```

---

## Development Guidelines

### Coding Rules

- **TypeScript strict**: `any` 사용 금지, `unknown` 우선 사용
- **Single Responsibility**: 컴포넌트, 훅, 함수는 하나의 명확한 책임만 가짐
- **DRY**: 3번 이상 반복되는 코드는 함수/컴포넌트로 추상화
- **ESLint/Prettier 규칙 비활성화 금지**: 불가피한 경우 외 `eslint-disable` 사용 금지
- **라이브러리 임의 설치 금지**: 새 의존성은 팀 논의 후 결정

### Component Guidelines

- `components/`: props로만 제어되는 재사용 순수 UI 컴포넌트
- `app/{feature}/(components)/`: 특정 기능에 의존하는 컴포넌트 (복수형 통일)
- 3개 이상의 훅 사용 또는 50줄 이상의 비즈니스 로직이 있으면 `useFeatureName` 커스텀 훅으로 분리
- DOM 직접 조작 로직(예: `downloadAnalysis`)은 `app/utils/`로 분리

### State Management

**서버 상태 (React Query)**:
- 모든 서버 데이터는 React Query로 관리
- Loading/Error 상태는 `Suspense`, `ErrorBoundary`로 선언적 처리 권장

**클라이언트 상태**:
- **Local State (`useState`)**: 컴포넌트 내부에서만 사용되는 데이터 우선
- **Global State (`Zustand`)**: 여러 페이지/기능에서 공유되는 최소한의 상태만 사용
- `useRootStore` 사용 시 반드시 `selector`로 필요한 상태만 구독 (불필요한 리렌더 방지)
- 상태 업데이트는 `use{Feature}Actions` 훅을 통해 일관되게 제공

### Networking (API)

모든 API 모듈은 3단계 구조를 따름:
1. **타입 정의** (`*.dto.ts`): `interface`로 Request/Response 타입 (API 함수와 별도 파일로 분리)
2. **API 호출 함수**: 순수 async 함수 (`getFeature`, `postFeature` 등)
3. **React Query 훅**: `use{Feature}Query` 또는 `use{Feature}Mutation`

추가 파일 패턴:
- **`*.helpers.ts`**: 도메인 타입 기반 순수 판별/변환 함수 (예: `isNewProperty`, `groupMedicalDepartments`)
- **`index.ts`**: barrel export로 도메인의 public API를 단일 진입점에서 노출

모든 요청은 `app/apis/(http-client)` 단일 인스턴스를 사용.

### Error Handling

- **UI 에러**: React `ErrorBoundary`로 선언적 처리
- **API 에러**: React Query의 `isError`, `error` + `useErrorToast` 결합
- **중요 에러**: Sentry 연동

### Naming Conventions

| 대상 | 규칙 | 예시 |
|------|------|------|
| 컴포넌트 | PascalCase | `ClientList.tsx` |
| 커스텀 훅 | camelCase + use 접두사 | `useClientQuery.tsx` |
| API 함수 | camelCase + HTTP method 접두사 | `getClientList.ts`, `postClient.ts` |
| 디렉토리 | kebab-case | `property-request/` |
| Zustand 슬라이스 | camelCase + Slice 접미사 | `clientSlice.ts` |
| DTO 타입 | PascalCase + 용도 접미사 | `ClientListResponse`, `ClientCreateRequest` |

---

## FSD Import Rules

- 상위 레이어 → 하위 레이어만 import 가능
- 동일 레이어 내 cross-import 금지
- `index.ts`를 통한 public API 노출 권장
- shared 레이어는 어디서든 import 가능
- **Barrel Export 패턴**: 새 코드 작성 시 도메인 barrel export를 활용
  ```typescript
  // 권장: barrel export 사용
  import { PropertyOne, usePropertyListQuery } from "@/app/apis/property";
  // 기존: 개별 파일에서 import (하위호환 유지됨)
  import { PropertyOne } from "@/app/apis/property/getPropertyList";
  ```
- **DTO 분리 원칙**: 타입 정의는 `*.dto.ts`에, API 함수는 `get*.ts`/`post*.ts` 등에 분리
- **Helpers 패턴**: 도메인 타입 기반 순수 함수는 `*.helpers.ts`에 배치

---

## Code Quality Principles

- **Simplicity**: 복잡한 솔루션보다 단순한 솔루션 우선
- **Guardrails**: 개발/프로덕션 환경에서 mock 데이터 사용 금지 (테스트 제외)
- **Minimal Intervention**: 최소한의 코드 변경으로 문제 해결
- **Progressive Enhancement**: 기존 코드 안정성 존중, 새 기능에서 점진적으로 개선

---

## 적용 체크리스트

코드 작성/리뷰 시 확인:

### Layer 의존성
- [ ] 상위 레이어 → 하위 레이어만 import 하는가?
- [ ] 동일 레이어 간 cross-import가 없는가?
- [ ] shared 레이어에 비즈니스 로직이 없는가?

### Entities vs Features
- [ ] 조회 로직(useQuery)이 entities에 있는가?
- [ ] 변경 로직(useMutation, Zustand)이 features에 있는가?
- [ ] entities → features 방향 import가 없는가?

### API 구조
- [ ] DTO가 `*.dto.ts`에 분리되어 있는가?
- [ ] API 함수가 HTTP method 접두사를 사용하는가?
- [ ] barrel export (`index.ts`)로 public API를 노출하는가?

### State Management
- [ ] 서버 상태가 React Query로 관리되는가?
- [ ] Zustand selector로 필요한 상태만 구독하는가?
- [ ] useState가 로컬 상태에만 사용되는가?

### Naming
- [ ] 컴포넌트: PascalCase, 훅: use 접두사, API: HTTP method 접두사?
- [ ] 디렉토리: kebab-case?
- [ ] DTO 타입: PascalCase + 용도 접미사?

---

## Communication

- 모든 응답, 설명은 한국어로 작성
- 코드 변경 시 이유와 핵심 변경점을 명확히 설명
- 불명확한 사항은 가정하지 않고 즉시 질문

---

## 이 스킬 사용법

FSD 아키텍처 원칙에 따라 코드를 작성하거나 리팩터링할 때 자동으로 적용합니다.

**트리거 키워드:**
- "FSD로 리팩터링해줘"
- "아키텍처 규칙에 맞게 수정해줘"
- "디렉토리 구조 정리해줘"
- 새 기능 구현 시 기본 적용
