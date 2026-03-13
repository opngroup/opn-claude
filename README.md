# opn-claude

> 오픈닥터 팀을 위한 Claude Code 커스텀 스킬 & 예시 페이지 모음

## 레포 구조

```
opn-claude/
├── skills/          ← 스킬 (.md)
├── examples/        ← 인터랙티브 예시 페이지 (.html)
├── scripts/         ← 자동화 스크립트
└── README.md
```

## 스킬 목록

| 스킬 | 파일 | 설명 | 트리거 키워드 |
| ---- | ---- | ---- | ------------- |
| **amplitude-naming** | `skills/amplitude-naming.md` | 앰플리튜드 이벤트 네이밍 생성기: 기능 설명을 입력하면 오픈닥터 네이밍 규칙에 맞는 이벤트명과 프로퍼티를 제안하고, 확인 후 노션 문서에 자동 기록합니다. | `앰플리튜드`, `amplitude`, `이벤트 네이밍` |
| **AX Weekly Report** | `skills/ax-report.md` | 한 주간의 AI 활용 기록을 정리하여 슬랙으로 발송하는 주간 AX 리포트 생성 스킬 | `ax-report`, `주간 리포트`, `AX 리포트` |
| **code-review** | `skills/code-review.md` | AI 코드 리뷰: 최근 변경된 코드를 분석하여 버그, 보안, 성능, 구조 이슈를 리뷰합니다. | `코드 리뷰`, `code review`, `리뷰 해줘` |
| **CS Interactive Tutor** | `skills/cs-tutor.md` | 일상 비유 + 작은 실습 + 게임 진행으로 CS 개념을 체득시키는 튜터링 스킬. 활성화 시 README 커리큘럼을 자동 생성하고 스테이지별 학습을 시작한다. | `CS 학습`, `CS 공부`, `네트워크 공부` |
| **OpnDoctor Frontend - Clean FSD Architecture** | `skills/fsd-architecture.md` | - | - |
| **토스 프론트엔드 클린 코드 스킬** | `skills/toss-clean-code.md` | - | - |
| **write-pr** | `skills/write-pr.md` | 프로젝트 PR 템플릿에 맞춰 PR 설명을 자동 작성 | `pr 작성`, `pr 작성해줘`, `write pr` |
| **push-example** | `skills/push-example.md` | 인터랙티브 예시 페이지를 opn-claude 레포의 examples/ 디렉터리에 푸시하고 README에 등록 | `예시 페이지 만들어줘`, `push example` |

## 예시 페이지

실무에서 적용한 기술을 인터랙티브하게 학습할 수 있는 단일 HTML 페이지 모음입니다.

| 예시 | 파일 | 설명 |
| ---- | ---- | ---- |
| **NaverMap 성능 최적화 가이드** | `examples/navermap-optimization.html` | React + 네이버맵 SDK 동기화 최적화 실전 가이드 (인터랙티브 데모 포함) |
| **Flutter → Next.js 마이그레이션 히스토리** | `examples/migration-history.html` | Flutter Web에서 Next.js로의 점진적 마이그레이션 성과 비교 대시보드 (개발 속도, 코드량, 기술 스택 비교) |
> 예시 페이지는 외부 의존성 없이 단일 HTML 파일로 구성되어 있어, 다운로드 후 바로 브라우저에서 열 수 있습니다.

---

## 사용 방법

### 1단계: 이 레포를 클론합니다

```bash
gh repo clone opngroup/opn-claude ~/opn-claude
```

### 2단계: 원하는 스킬을 프로젝트에 등록합니다

```bash
# 방법 A: 심볼릭 링크 (추천 - 업데이트 자동 반영)
ln -s ~/opn-claude/skills/code-review.md /your-project/.claude/skills/code-review.md

# 방법 B: 직접 복사
cp ~/opn-claude/skills/code-review.md /your-project/.claude/skills/code-review.md
```

### 3단계: Claude Code에서 트리거 키워드를 말합니다

```
# 예시: 코드 리뷰 스킬
> 코드 리뷰 해줘

# 예시: PR 작성 스킬
> PR 작성해줘

# 예시: 앰플리튜드 네이밍
> 앰플리튜드 이벤트 네이밍 만들어줘
```

### 예시 페이지 보는 법

```bash
# 브라우저에서 바로 열기
open ~/opn-claude/examples/navermap-optimization.html
```

---

## 기여 방법

### 스킬 추가하기

1. **자동**: `#공부방_ai` 슬랙 채널에 `.md` 스킬 파일을 업로드하면 자동으로 PR이 생성됩니다.
2. **수동**: `skills/` 디렉터리에 `.md` 파일을 추가하고 PR을 올려주세요.
3. **Claude Code 활용**: 작업 중 유용한 스킬을 만들었다면 Claude에게 "이 스킬 opn-claude에 올려줘"라고 말하면 자동으로 PR을 만들어줍니다.

### 예시 페이지 추가하기

Claude Code에게 아래처럼 말하면 됩니다:

```
# 예시 1: 작업 중 배운 내용을 예시 페이지로 만들어서 올리기
> React Query 캐싱 전략 예시 페이지 만들어서 opn-claude에 올려줘

# 예시 2: 이미 만든 HTML 파일을 올리기
> 이 가이드 페이지 opn-claude examples에 푸시해줘
```

자동으로 `examples/` 디렉터리에 추가하고, 이 README 테이블에 등록한 뒤, PR을 생성합니다.

### 기여 규칙

- **스킬**: `skills/` 디렉터리에 `.md` 파일로 추가
- **예시 페이지**: `examples/` 디렉터리에 단일 `.html` 파일로 추가 (외부 의존성 X)
- PR 리뷰 후 머지하면 README가 자동 갱신됩니다
