# 토스 프론트엔드 클린 코드 스킬

> 기반: [Frontend Fundamentals](https://frontend-fundamentals.com/code-quality/) by Toss

## 핵심 철학

**좋은 코드 = 변경하기 쉬운 코드**

새로운 요구사항을 구현할 때 쉽게 수정하고 배포할 수 있는 코드가 좋은 코드입니다.

---

## 4가지 핵심 원칙

### 1. 가독성 (Readability)

코드를 읽을 때 고려해야 할 맥락이 적고, 위에서 아래로 자연스럽게 읽히는 코드

#### 1-1. 맥락 줄이기

**동시에 실행되지 않는 코드 분리하기**
```tsx
// ❌ Bad - 조건문 안에서 다양한 맥락 혼합
function Component({ status }) {
  if (status === 'loading') {
    return <Loading />;
  }
  if (status === 'error') {
    return <Error />;
  }
  // 50줄의 성공 로직...
}

// ✅ Good - 각 상태를 별도 컴포넌트로 분리
function Component({ status }) {
  if (status === 'loading') return <Loading />;
  if (status === 'error') return <Error />;
  return <SuccessContent />;
}
```

**구현 상세 추상화하기**
```tsx
// ❌ Bad - 구현 상세가 노출됨
const isAdmin = user.roles.includes('admin') || user.roles.includes('superadmin');

// ✅ Good - 의도가 명확한 함수로 추상화
const isAdmin = hasAdminRole(user);
```

**로직 유형별로 함수 분리하기**
```tsx
// ❌ Bad - 여러 관심사가 한 함수에 혼합
function handleSubmit() {
  validateForm();
  transformData();
  callAPI();
  showNotification();
  navigateToNextPage();
}

// ✅ Good - 각 관심사를 별도 함수로
function handleSubmit() {
  const validationResult = validateForm();
  if (!validationResult.isValid) return;

  submitData();
}
```

#### 1-2. 이름 붙이기

**복잡한 조건에 이름 붙이기**
```tsx
// ❌ Bad - 조건의 의미를 파악하기 어려움
if (user.age >= 19 && user.hasVerified && !user.isBanned) {
  // ...
}

// ✅ Good - 조건의 의도가 명확
const canAccessAdultContent = user.age >= 19 && user.hasVerified && !user.isBanned;
if (canAccessAdultContent) {
  // ...
}
```

**매직 넘버에 이름 붙이기**
```tsx
// ❌ Bad - 숫자의 의미를 알 수 없음
if (items.length > 10) {
  showPagination();
}

// ✅ Good - 상수로 의미 부여
const MAX_ITEMS_PER_PAGE = 10;
if (items.length > MAX_ITEMS_PER_PAGE) {
  showPagination();
}
```

#### 1-3. 위에서 아래로 읽히게 하기

**Early Return으로 중첩 줄이기**
```tsx
// ❌ Bad - 깊은 중첩
function process(data) {
  if (data) {
    if (data.isValid) {
      if (data.hasPermission) {
        return doSomething(data);
      }
    }
  }
  return null;
}

// ✅ Good - Early Return
function process(data) {
  if (!data) return null;
  if (!data.isValid) return null;
  if (!data.hasPermission) return null;

  return doSomething(data);
}
```

**삼항 연산자 단순화**
```tsx
// ❌ Bad - 중첩된 삼항 연산자
const result = a ? (b ? 'A' : 'B') : (c ? 'C' : 'D');

// ✅ Good - if-else 또는 객체 맵핑
const resultMap = {
  'case1': 'A',
  'case2': 'B',
  // ...
};
const result = resultMap[getCase(a, b, c)];
```

---

### 2. 예측 가능성 (Predictability)

함수나 컴포넌트의 이름, 파라미터, 반환값만 보고도 동작을 예측할 수 있는 코드

#### 2-1. 이름 겹치지 않게 관리하기
```tsx
// ❌ Bad - 같은 이름이 다른 의미로 사용
const user = fetchUser(); // API 응답
const user = { name, email }; // 로컬 상태

// ✅ Good - 명확하게 구분
const fetchedUser = fetchUser();
const formUser = { name, email };
```

#### 2-2. 유사한 함수의 반환 타입 통일하기
```tsx
// ❌ Bad - 비슷한 함수가 다른 타입 반환
function getUserById(id) {
  return user || null;
}
function getUserByEmail(email) {
  return user || undefined;
}

// ✅ Good - 일관된 반환 타입
function getUserById(id): User | null {
  return user || null;
}
function getUserByEmail(email): User | null {
  return user || null;
}
```

#### 2-3. 숨은 로직 드러내기
```tsx
// ❌ Bad - 부수 효과가 숨겨져 있음
function formatPrice(price) {
  analytics.track('price_viewed'); // 예상치 못한 부수 효과
  return `${price.toLocaleString()}원`;
}

// ✅ Good - 함수 이름에 동작 명시 또는 분리
function formatPrice(price) {
  return `${price.toLocaleString()}원`;
}

function formatPriceWithTracking(price) {
  analytics.track('price_viewed');
  return formatPrice(price);
}
```

---

### 3. 응집도 (Cohesion)

함께 수정되어야 하는 코드가 함께 수정되도록 구조화된 코드

#### 3-1. 함께 수정되는 파일을 같은 디렉토리에 두기
```
// ❌ Bad - 종류별 분류
src/
├─ components/
│  ├─ PaymentButton.tsx
│  └─ PaymentForm.tsx
├─ hooks/
│  └─ usePayment.ts
└─ utils/
   └─ paymentUtils.ts

// ✅ Good - 도메인별 분류
src/
├─ shared/
│  ├─ components/
│  └─ hooks/
└─ domains/
   └─ payment/
      ├─ components/
      │  ├─ PaymentButton.tsx
      │  └─ PaymentForm.tsx
      ├─ hooks/
      │  └─ usePayment.ts
      └─ utils/
         └─ paymentUtils.ts
```

#### 3-2. 매직 넘버 없애기
```tsx
// ❌ Bad - 매직 넘버가 여러 곳에 분산
// file1.ts
if (retryCount > 3) { ... }

// file2.ts
for (let i = 0; i < 3; i++) { retry(); }

// ✅ Good - 상수로 중앙 관리
// constants.ts
export const MAX_RETRY_COUNT = 3;

// file1.ts, file2.ts
import { MAX_RETRY_COUNT } from './constants';
```

#### 3-3. 폼의 응집도 고려하기
```tsx
// ❌ Bad - 폼 상태가 분산됨
const [name, setName] = useState('');
const [email, setEmail] = useState('');
const [phone, setPhone] = useState('');

// ✅ Good - 폼 상태를 함께 관리
const [form, setForm] = useState({
  name: '',
  email: '',
  phone: '',
});

// 또는 react-hook-form 사용
const { register, handleSubmit } = useForm<FormData>();
```

---

### 4. 결합도 (Coupling)

코드 수정 시 영향 범위가 제한적인 코드

#### 4-1. 책임을 하나씩 관리하기
```tsx
// ❌ Bad - 하나의 컴포넌트가 여러 책임
function UserDashboard() {
  // 데이터 fetching
  // 필터링 로직
  // 정렬 로직
  // 렌더링
  // 이벤트 핸들링
}

// ✅ Good - 책임 분리
function UserDashboard() {
  const { users } = useUsers();
  const filteredUsers = useFilteredUsers(users);

  return <UserList users={filteredUsers} />;
}
```

#### 4-2. 중복 코드 허용하기

**DRY보다 명확성 우선**
```tsx
// 섣부른 추상화보다 명확한 중복이 나을 때가 있음

// ❌ 과도한 추상화 - 오히려 이해하기 어려움
function Button({ variant }) {
  const styles = getButtonStyles(variant); // 복잡한 추상화
  // ...
}

// ✅ 명시적 중복 - 각 버튼의 스타일이 명확
function PrimaryButton() {
  return <button className="bg-blue-500 text-white" />;
}

function SecondaryButton() {
  return <button className="bg-gray-200 text-gray-800" />;
}
```

#### 4-3. Props Drilling 제거하기
```tsx
// ❌ Bad - Props Drilling
function GrandParent() {
  const [user, setUser] = useState();
  return <Parent user={user} setUser={setUser} />;
}

function Parent({ user, setUser }) {
  return <Child user={user} setUser={setUser} />;
}

function Child({ user, setUser }) {
  // 실제로 사용
}

// ✅ Good - Context 또는 상태 관리 라이브러리 활용
const UserContext = createContext();

function GrandParent() {
  const [user, setUser] = useState();
  return (
    <UserContext.Provider value={{ user, setUser }}>
      <Parent />
    </UserContext.Provider>
  );
}

function Child() {
  const { user, setUser } = useContext(UserContext);
  // ...
}
```

---

## 원칙 간 트레이드오프

> 4가지 원칙을 동시에 만족하기는 어렵습니다.

| 상황 | 우선순위 | 이유 |
|------|----------|------|
| 함께 수정하지 않으면 에러 발생 | 응집도 > 가독성 | 버그 방지가 더 중요 |
| 위험도가 낮은 중복 | 가독성 > 응집도 | 중복을 허용하고 명확성 확보 |
| 영향 범위 제한 필요 | 결합도 > 응집도 | 변경 용이성 확보 |

---

## 적용 체크리스트

코드 작성/리뷰 시 확인:

### 가독성
- [ ] 함수가 한 가지 일만 하는가?
- [ ] 중첩 깊이가 2단계 이하인가?
- [ ] 조건문이 이름으로 의도를 설명하는가?
- [ ] 매직 넘버 대신 상수를 사용했는가?

### 예측 가능성
- [ ] 함수 이름이 동작을 정확히 설명하는가?
- [ ] 유사한 함수의 반환 타입이 일관적인가?
- [ ] 숨겨진 부수 효과가 없는가?

### 응집도
- [ ] 관련 파일이 같은 디렉토리에 있는가?
- [ ] 함께 수정되는 코드가 함께 있는가?
- [ ] 폼 상태가 적절히 그룹화되어 있는가?

### 결합도
- [ ] 컴포넌트가 단일 책임을 갖는가?
- [ ] Props Drilling 없이 상태를 공유하는가?
- [ ] 불필요한 추상화가 없는가?

---

## 이 스킬 사용법

코드 작성 또는 리뷰 요청 시 이 원칙들을 자동으로 적용합니다.

**트리거 키워드:**
- "클린 코드로 작성해줘"
- "토스 스타일로"
- "코드 리뷰해줘"
- 모든 코드 작성/수정 작업 시 기본 적용
