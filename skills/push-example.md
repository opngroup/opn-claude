---
name: push-example
description: 인터랙티브 예시 페이지를 opn-claude 레포의 examples/ 디렉터리에 푸시하고 README에 등록
triggers:
  - "예시 페이지 만들어줘"
  - "example 페이지"
  - "push example"
  - "opn-claude example"
scope: project
---

# Push Example to opn-claude

## Purpose

인터랙티브 예시/가이드 HTML 페이지를 만들어 `opngroup/opn-claude` 레포의 `examples/` 디렉터리에 푸시하고 README에 자동 등록합니다.

## Workflow

### 1. 예시 페이지 생성
- 사용자가 요청한 주제로 단일 HTML 파일 (인터랙티브, 한국어, 다크 테마) 생성
- 외부 의존성 없이 CSS/JS 인라인으로 완성

### 2. opn-claude 레포 클론 및 브랜치 생성
```bash
# 임시 디렉터리에 클론
TEMP_DIR=$(mktemp -d)
gh repo clone opngroup/opn-claude "$TEMP_DIR/opn-claude"
cd "$TEMP_DIR/opn-claude"

# 브랜치 생성
git checkout -b feat/example-{{EXAMPLE_NAME}}
```

### 3. examples 디렉터리 확인 (있으면 생성하지 않음)
```bash
# 디렉터리가 없을 때만 생성
if [ ! -d "examples" ]; then
  mkdir examples
fi
```

### 4. 파일 복사 및 커밋
```bash
cp {{SOURCE_HTML_PATH}} examples/{{EXAMPLE_NAME}}.html
git add examples/
git commit -m "feat: {{EXAMPLE_NAME}} 예시 페이지 추가"
```

### 5. README.md 업데이트
- README.md에 `## 예시 페이지` 섹션이 없으면 추가
- 테이블에 새 예시 항목 추가:

```markdown
## 예시 페이지

| 예시 | 파일 | 설명 |
| ---- | ---- | ---- |
| **{{TITLE}}** | `examples/{{EXAMPLE_NAME}}.html` | {{DESCRIPTION}} |
```

- 섹션이 이미 있으면 테이블에 행만 추가

```bash
git add README.md
git commit -m "docs: README에 {{EXAMPLE_NAME}} 예시 등록"
```

### 6. Push 및 PR 생성
```bash
git push -u origin feat/example-{{EXAMPLE_NAME}}
gh pr create --base main \
  --title "feat: {{EXAMPLE_NAME}} 예시 페이지 추가" \
  --body "## Summary
- {{DESCRIPTION}}
- 단일 HTML 파일, 외부 의존성 없음
- 인터랙티브 데모 포함

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
```

### 7. 정리
```bash
rm -rf "$TEMP_DIR"
```

## Variables
- `{{EXAMPLE_NAME}}`: 예시 파일명 (kebab-case, e.g., `navermap-optimization`)
- `{{TITLE}}`: 예시 제목 (e.g., `NaverMap 성능 최적화 가이드`)
- `{{DESCRIPTION}}`: 한 줄 설명
- `{{SOURCE_HTML_PATH}}`: 원본 HTML 파일 경로

## Notes
- 항상 단일 HTML 파일로 생성 (외부 의존성 X)
- 한국어 + 다크 테마 + 인터랙티브 데모 포함
- examples/ 디렉터리가 이미 있으면 생성하지 않음
- README의 예시 페이지 섹션이 이미 있으면 테이블에 행만 추가
