# opn-claude

> 오픈닥터 팀을 위한 Claude Code 커스텀 스킬 모음

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

| 예시 | 파일 | 설명 |
| ---- | ---- | ---- |
| **NaverMap 성능 최적화 가이드** | `examples/navermap-optimization.html` | React + 네이버맵 SDK 동기화 최적화 실전 가이드 (인터랙티브 데모 포함) |

## 사용 방법

이 레포의 `skills/` 디렉터리에 있는 `.md` 파일들을 Claude Code의 로컬 스킬로 등록하면, 트리거 키워드 입력 시 자동으로 해당 스킬이 활성화됩니다.

## 스킬 추가 방법

1. `#공부방_ai` 슬랙 채널에 `.md` 스킬 파일을 업로드하면 자동으로 PR이 생성됩니다.
2. 팀원 리뷰 후 머지하면 README가 자동 갱신됩니다.

수동으로 추가하려면 `skills/` 디렉터리에 `.md` 파일을 추가하고 PR을 올려주세요.
