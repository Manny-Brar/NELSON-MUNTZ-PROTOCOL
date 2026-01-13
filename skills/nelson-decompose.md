---
name: nelson-decompose
description: "Feature decomposition protocol for Nelson Muntz initialization"
---

# Nelson Decompose - Feature Decomposition Protocol

## Purpose
Break down complex tasks into atomic, single-iteration features that can be completed independently with clear verification criteria.

---

## DECOMPOSITION PRINCIPLES

### Principle 1: Single-Iteration Completable
Each feature must be completable in ONE Nelson iteration:
- Typically 15-45 minutes of focused work
- If it feels like "a lot" → break it down further

### Principle 2: Independently Verifiable
Each feature must have clear pass/fail verification:
- Can run a test
- Can see visual result
- Can verify behavior

### Principle 3: Minimal Dependencies
Order features to minimize blocking:
- Foundation features first
- Dependent features after their dependencies

### Principle 4: Atomic Commits
Each feature = one logical git commit:
- If you can't describe it in one commit message, it's too big

---

## DECOMPOSITION PROCESS

### Step 1: Identify Core Capabilities
From the original prompt, list what the system must DO:
```
Original: "Build a REST API with user authentication"

Core Capabilities:
- Accept HTTP requests
- Authenticate users
- Protect routes
- Return JSON responses
```

### Step 2: Expand to Implementation Units
For each capability, identify implementation units:
```
"Authenticate users" →
- User registration endpoint
- User login endpoint
- JWT token generation
- Token validation middleware
- Password hashing
```

### Step 3: Order by Dependencies
```
1. Project setup (no deps)
2. User model (needs setup)
3. Password hashing (needs user model)
4. Registration endpoint (needs hashing)
5. JWT generation (needs setup)
6. Login endpoint (needs JWT, hashing)
7. Validation middleware (needs JWT)
8. Protected routes (needs middleware)
9. Tests (needs all above)
```

### Step 4: Define Verification for Each
```
F1: Project setup
    Verify: `npm run dev` starts without errors

F2: User model
    Verify: Can create user in database via script

F3: Password hashing
    Verify: Unit test passes for hash/compare

...
```

---

## FEATURES.JSON SCHEMA

```json
{
  "version": "3.0.0",
  "created_at": "2026-01-13T12:00:00Z",
  "last_updated": "2026-01-13T12:00:00Z",
  "original_prompt": "The original task prompt",
  "features": [
    {
      "id": "F1",
      "name": "Short descriptive name",
      "description": "What this feature does",
      "priority": 1,
      "status": "pending",
      "steps": [
        "Specific step 1",
        "Specific step 2",
        "Specific step 3"
      ],
      "verification": {
        "command": "npm run test:auth",
        "expected": "All tests pass",
        "manual_check": "Can login via API"
      },
      "files": [
        "src/auth/index.ts",
        "src/middleware/auth.ts"
      ],
      "blocked_by": [],
      "passes": false,
      "attempts": 0,
      "notes": ""
    }
  ],
  "summary": {
    "total": 8,
    "completed": 0,
    "blocked": 0,
    "in_progress": 0,
    "pending": 8
  }
}
```

---

## FEATURE SIZE GUIDELINES

### TOO BIG (Break Down Further):
- "Build authentication system" → 5-8 features
- "Create user management" → 3-5 features
- "Add API endpoints" → 1 per endpoint

### RIGHT SIZE (Single Feature):
- "Add user registration endpoint"
- "Implement JWT token generation"
- "Create password hashing utility"
- "Add auth middleware"
- "Write tests for login endpoint"

### TOO SMALL (Combine):
- "Create user file" → Combine with model implementation
- "Add import statement" → Part of larger feature
- "Fix typo" → Part of feature or separate bugfix

---

## DECOMPOSITION TEMPLATE

For each feature, fill out:

```markdown
## F[N]: [Feature Name]

**Description:** [1-2 sentences]

**Steps:**
1. [Concrete action 1]
2. [Concrete action 2]
3. [Concrete action 3]

**Verification:**
- Command: `[test command]`
- Expected: [what success looks like]

**Files:**
- `path/to/file1.ts`
- `path/to/file2.ts`

**Dependencies:** [F1, F3] or "None"

**Estimated Complexity:** Low / Medium / High
```

---

## COMMON DECOMPOSITION PATTERNS

### API Feature Pattern:
```
F1: Create data model/types
F2: Create database migration
F3: Create repository/service layer
F4: Create API endpoint
F5: Add input validation
F6: Add error handling
F7: Write tests
```

### UI Feature Pattern:
```
F1: Create component shell
F2: Add state management
F3: Implement core logic
F4: Add styling
F5: Add loading/error states
F6: Add accessibility
F7: Write tests
```

### Integration Pattern:
```
F1: Set up client/SDK
F2: Implement auth flow
F3: Create wrapper functions
F4: Add error handling
F5: Add retry logic
F6: Write integration tests
```

---

## DECOMPOSITION CHECKLIST

Before finalizing features.json:

```
[ ] Each feature is single-iteration completable
[ ] Each feature has clear verification criteria
[ ] Dependencies are mapped and ordered correctly
[ ] No feature depends on unplanned work
[ ] Feature names are descriptive and unique
[ ] Steps are concrete and actionable
[ ] Files are identified where possible
[ ] Priority order makes sense
[ ] Total features is reasonable (typically 5-15 for most tasks)
```

---

## DECOMPOSITION ANTI-PATTERNS

### Anti-Pattern 1: Vague Features
- BAD: "Implement backend logic"
- GOOD: "Create user registration endpoint with email validation"

### Anti-Pattern 2: Overlapping Features
- BAD: F1: "Add auth", F2: "Add login" (login IS auth)
- GOOD: F1: "Add registration", F2: "Add login", F3: "Add logout"

### Anti-Pattern 3: Missing Dependencies
- BAD: F1: "Add protected routes" (before auth exists)
- GOOD: F1: "Add auth middleware", F2: "Add protected routes"

### Anti-Pattern 4: Monster Features
- BAD: F1: "Build complete user system with auth, profiles, settings, and admin"
- GOOD: Split into 8-10 atomic features

---

## COMPLEXITY ESTIMATION

Use this guide for complexity:

| Complexity | Typical Time | Example |
|------------|--------------|---------|
| Low | 10-15 min | Add utility function, create model |
| Medium | 20-30 min | Add API endpoint, create component |
| High | 30-45 min | Complex integration, multi-file refactor |

If estimated > 45 min → Break down further

---

*Run this decomposition during Iteration 1 (Initializer) before any implementation.*
