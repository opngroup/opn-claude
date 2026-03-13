---
id: ax-report
name: AX Weekly Report
description: 한 주간의 AI 활용 기록을 정리하여 슬랙으로 발송하는 주간 AX 리포트 생성 스킬
source: custom
triggers:
  - "ax-report"
  - "주간 리포트"
  - "AX 리포트"
  - "AI 활용 리포트"
  - "이번 주 리포트"
quality: high
---

# AX Weekly Report Generator

## The Insight

AI를 "쓰는 것"과 AI를 "잘 쓰는 것"은 다르다. 매주 자신의 AI 활용 패턴을 되돌아보고 공유하면, 팀 전체의 AX(AI Experience) 수준이 올라간다.

## Recognition Pattern

사용자가 다음과 같이 말할 때 이 스킬을 활성화한다:
- "/ax-report", "주간 리포트 만들어줘"
- "이번 주 AI 활용 정리해줘"
- "AX 리포트 보내줘"
- "슬랙에 리포트 보내줘"

## The Approach

### 1. 주간 기록 수집

Memory 디렉토리에서 `ax-weekly-log.md`를 읽어 현재 주차의 기록을 수집한다.

```
파일 경로: ~/.claude/projects/-Users-juyoung-Desktop-my-work/memory/ax-weekly-log.md
```

현재 주차(월요일~일요일)에 해당하는 기록만 추출한다.

### 2. 리포트 생성

다음 구조로 리포트를 작성한다:

```markdown
# 🤖 주간 AX 리포트 - [주차]

## 이번 주 한 줄 요약
> [가장 인상적인 AI 활용 1가지를 한 줄로]

## AI 활용 기록

### [날짜] [작업 제목]
**어떻게 활용했나**: [활용 방식]
**결과는**: [결과 요약]
**배운 점**: [인사이트]

(반복)

## 이번 주 AX 인사이트
- [패턴 분석: 어떤 유형의 작업에 AI를 가장 많이 활용했는지]
- [효과 분석: 가장 효과적이었던 활용 방식]
- [개선 포인트: 다음 주에 시도해볼 것]

## 숫자로 보는 이번 주
- AI 활용 건수: N건
- 주요 활용 분야: [코드생성, 설계, 자동화 등]
- 가장 많이 쓴 도구/모드: [ralph, autopilot 등]

---
by Claude Code AX Observer | [날짜]
```

### 3. 슬랙 발송

설정 파일에서 웹훅 URL을 읽어 슬랙으로 발송한다.

```bash
CONFIG_FILE="$HOME/.claude/.ax-report-config.json"
```

**설정 파일 형식:**
```json
{
  "slack_webhook_url": "https://hooks.slack.com/services/...",
  "channel_name": "#ax-report"
}
```

**발송 방법:**
```bash
curl -X POST -H 'Content-Type: application/json' \
  -d '{"text": "[리포트 내용]"}' \
  "$WEBHOOK_URL"
```

**설정이 없는 경우:**
- 사용자에게 슬랙 웹훅 URL을 요청한다
- 입력받은 URL을 설정 파일에 저장한다
- 이후 자동으로 해당 URL을 사용한다

### 4. 리포트 발송 후

- 발송 성공 시 사용자에게 확인 메시지
- `ax-weekly-log.md`에 해당 주차 리포트 발송 완료 표시 추가
- 기록은 삭제하지 않음 (아카이브로 유지)

## 기록이 없을 때

만약 해당 주차에 기록된 AI 활용 내역이 없으면:
1. 현재 세션에서 대화 내용을 기반으로 이번 주 활용 내역을 회고
2. 사용자에게 "이번 주에 AI로 한 작업이 있나요?"라고 물어봄
3. 답변을 기반으로 리포트 생성

## 주의사항

- 리포트는 **읽기 쉽고 짧게** 작성 (슬랙에서 읽기 좋은 분량)
- 기술 용어보다 **실용적 표현** 사용
- 자랑이 아닌 **관찰과 학습** 관점으로 작성
- 슬랙 메시지 형식에 맞게 마크다운 변환 (Slack mrkdwn 문법)
