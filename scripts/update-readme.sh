#!/bin/bash
# 스킬 .md 파일들을 파싱하여 README.md 테이블을 자동 갱신하는 스크립트

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
README="$REPO_ROOT/README.md"

# frontmatter에서 name 추출
get_name() {
  local file="$1"
  sed -n '/^---$/,/^---$/p' "$file" | grep -m1 '^name:' | sed 's/^name:[[:space:]]*//' || true
}

# 첫 번째 # 제목 추출
get_title() {
  local file="$1"
  grep -m1 '^# ' "$file" | sed 's/^# //' || true
}

# description 추출: frontmatter의 description 필드 첫 번째 텍스트 줄
get_description() {
  local file="$1"
  local in_desc=false
  local result=""

  while IFS= read -r line; do
    if [[ "$line" =~ ^description: ]]; then
      # 한 줄짜리 description
      local val="${line#description:}"
      val="$(echo "$val" | sed 's/^[[:space:]]*//' | sed 's/|//' | sed 's/>//')"
      if [[ -n "$val" ]]; then
        result="$val"
        break
      fi
      in_desc=true
      continue
    fi

    if $in_desc; then
      # frontmatter 끝이거나 다른 필드 시작이면 중단
      if [[ "$line" =~ ^[a-z_-]+: ]] || [[ "$line" == "---" ]]; then
        break
      fi
      # 실제 텍스트 줄 (MANDATORY TRIGGERS 줄 제외)
      local trimmed="$(echo "$line" | sed 's/^[[:space:]]*//')"
      if [[ -n "$trimmed" && ! "$trimmed" =~ ^- && ! "$trimmed" =~ MANDATORY ]]; then
        result="$trimmed"
        break
      fi
      # - 로 시작하는 줄도 무시하지 말고 첫 텍스트 줄이면 사용
      if [[ -n "$trimmed" && "$trimmed" =~ ^\*\* ]]; then
        result="$(echo "$trimmed" | sed 's/\*\*//g' | sed 's/:[[:space:]]*/: /')"
        break
      fi
    fi
  done < <(sed -n '/^---$/,/^---$/p' "$file")

  # **bold** 제거, 80자 제한
  echo "$result" | sed 's/\*\*//g' | cut -c1-100
}

# 트리거 키워드 추출
get_triggers() {
  local file="$1"
  local triggers=""

  # 방법 1: triggers 배열 (YAML 리스트)
  triggers=$(sed -n '/^---$/,/^---$/p' "$file" | sed -n '/^triggers:/,/^[a-z_-]*:/p' | grep '^\s*-' | sed 's/^[[:space:]]*-[[:space:]]*//' | sed 's/^"//' | sed 's/"$//' | sed "s/^'//" | sed "s/'$//" | head -3 | tr '\n' '|')

  # 방법 2: MANDATORY TRIGGERS 줄
  if [[ -z "$triggers" ]]; then
    triggers=$(sed -n '/^---$/,/^---$/p' "$file" | grep -o 'MANDATORY TRIGGERS:.*' | sed 's/MANDATORY TRIGGERS:[[:space:]]*//' | tr ',' '|' | head -1)
  fi

  # | 구분을 백틱 포맷으로 변환
  if [[ -n "$triggers" ]]; then
    echo "$triggers" | tr '|' '\n' | sed '/^$/d' | head -3 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sed 's/^/`/' | sed 's/$/`/' | paste -sd',' - | sed 's/,/, /g'
  else
    echo "-"
  fi
}

# 스킬 파일 수집 (README 제외)
SKILLS=()
for file in "$REPO_ROOT"/*.md; do
  [[ "$(basename "$file")" == "README.md" ]] && continue
  SKILLS+=("$file")
done

if [[ ${#SKILLS[@]} -eq 0 ]]; then
  echo "No skill files found."
  exit 0
fi

# 테이블 행 생성
TABLE_ROWS=""
for file in "${SKILLS[@]}"; do
  filename="$(basename "$file")"

  name=$(get_name "$file")
  [[ -z "$name" ]] && name=$(get_title "$file")
  [[ -z "$name" ]] && name="$filename"

  desc=$(get_description "$file")
  [[ -z "$desc" ]] && desc="-"

  triggers=$(get_triggers "$file")

  TABLE_ROWS="${TABLE_ROWS}| **${name}** | \`${filename}\` | ${desc} | ${triggers} |
"
done

# README 생성
cat > "$README" << 'HEADER'
# opn-claude

> 오픈닥터 팀을 위한 Claude Code 커스텀 스킬 모음

## 스킬 목록

| 스킬 | 파일 | 설명 | 트리거 키워드 |
| ---- | ---- | ---- | ------------- |
HEADER

printf '%s' "$TABLE_ROWS" >> "$README"

cat >> "$README" << 'FOOTER'

## 사용 방법

이 레포의 `.md` 파일들을 Claude Code의 로컬 스킬로 등록하면, 트리거 키워드 입력 시 자동으로 해당 스킬이 활성화됩니다.

## 스킬 추가 방법

1. `#공부방_ai` 슬랙 채널에 `.md` 스킬 파일을 업로드하면 자동으로 PR이 생성됩니다.
2. 팀원 리뷰 후 머지하면 README가 자동 갱신됩니다.

수동으로 추가하려면 루트에 `.md` 파일을 추가하고 PR을 올려주세요.
FOOTER

echo "README.md updated with ${#SKILLS[@]} skills."
