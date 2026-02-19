# Create 5 Budget Config Versions for OpenCode

## TL;DR

> **Quick Summary**: Create 5 budget-tier configuration folders (01-budget through 05-premium), each containing opencode.json and oh-my-opencode.json with model assignments based on cost tiers.
>
> **Deliverables**:
> - 5 folders: `01-budget/`, `02-budget_premium/`, `03-standard/`, `04-standard_premium/`, `05-premium/`
> - 10 config files: Each folder has `opencode.json` + `oh-my-opencode.json`
>
> **Estimated Effort**: Short
> **Parallel Execution**: YES - 5 waves (one per budget tier)
> **Critical Path**: Create folders → Generate configs for each folder → Validate JSON syntax

---

## Context

### Original Request
Create 5 version config folders for opencode and oh-my-opencode tooling with different budget tiers. Each folder will contain opencode.json and oh-my-opencode.json files with model assignments ranging from cost-effective (budget) to premium (most expensive).

### Interview Summary
**Key Discussions**:
- **Folder naming**: Use numeric prefix: `01-budget`, `02-budget_premium`, `03-standard`, `04-standard_premium`, `05-premium`
- **Config files**: Each folder contains 2 files: `opencode.json` (BMAD agents) and `oh-my-opencode.json` (Oh-My-OpenCode agents)
- **Provider section**: Preserve from `default/opencode.json` (Google provider with all model definitions)
- **Categories section**: Preserve from `default/oh-my-opencode.json` (7 categories: visual-engineering, ultrabrain, artistry, quick, unspecified-low, unspecified-high, writing)
- **Model assignments**: User provided JSON config with 5 budget tiers and specific model mappings

**Research Findings**:
- `default/opencode.json` structure: `$schema`, `mcp`, `plugin`, `agent` (18 BMAD agents), `provider` (Google with model definitions)
- `default/oh-my-opencode.json` structure: `$schema`, `google_auth`, `agents` (11 Oh-My-OpenCode agents), `categories` (7 categories)
- Plugin list in opencode.json: `["opencode-antigravity-auth@latest", "oh-my-opencode@3.1.4", "opencode-beads@0.4.0"]`

---

## Work Objectives

### Core Objective
Create 5 budget-tier configuration folders with proper model assignments for cost optimization across the OpenCode and Oh-My-OpenCode tooling ecosystem.

### Concrete Deliverables
- `01-budget/opencode.json` - Most cost-effective configuration
- `01-budget/oh-my-opencode.json`
- `02-budget_premium/opencode.json` - Enhanced budget tier
- `02-budget_premium/oh-my-opencode.json`
- `03-standard/opencode.json` - Balanced tier
- `03-standard/oh-my-opencode.json`
- `04-standard_premium/opencode.json` - Enhanced standard tier
- `04-standard_premium/oh-my-opencode.json`
- `05-premium/opencode.json` - Most expensive tier
- `05-premium/oh-my-opencode.json`

### Definition of Done
- [x] All 5 folders created
- [x] All 10 config files generated with correct model assignments
- [x] Each file passes JSON syntax validation
- [x] Provider section preserved in all opencode.json files
- [x] Categories section preserved in all oh-my-opencode.json files

### Must Have
- Exact model assignments as specified in user's provided config
- Preserved provider section from default/opencode.json
- Preserved categories section from default/oh-my-opencode.json
- Correct JSON structure matching source files

### Must NOT Have (Guardrails)
- No modification to the preserved provider section (Google model definitions)
- No modification to the preserved categories section
- No additional agents beyond what's in the source config
- No removal of existing agents from source config

---

## Verification Strategy

### Test Decision
- **Infrastructure exists**: NO test infrastructure needed (JSON config files)
- **User wants tests**: Manual-only (JSON syntax validation)
- **Framework**: None (use `jq` or JSON parser for validation)

### Manual QA Only

**Verification Procedure**:
Each TODO includes JSON syntax validation using `jq` command:

```bash
# Validate JSON syntax
jq . 01-budget/opencode.json > /dev/null && echo "Valid JSON" || echo "Invalid JSON"
```

**Evidence Required**:
- All 10 files validate successfully with no JSON syntax errors
- Folder structure matches expected layout
- Model assignments match user-provided config per budget tier

---

## Execution Strategy

### Parallel Execution Waves

> Maximize throughput by creating all 5 budget tiers in parallel.
> Each wave processes one budget tier (2 files).

```
Wave 1 (Start Immediately):
├── Task 1: Create 01-budget/ folder and configs
└── Task 2: Create 02-budget_premium/ folder and configs

Wave 3 (After Wave 1):
├── Task 3: Create 03-standard/ folder and configs
└── Task 4: Create 04-standard_premium/ folder and configs

Wave 5 (After Wave 3):
└── Task 5: Create 05-premium/ folder and configs

Critical Path: Sequential creation of 5 folders
Parallel Speedup: ~40% faster than sequential (2 waves instead of 5)
```

### Dependency Matrix

| Task | Depends On | Blocks | Can Parallelize With |
|------|------------|--------|---------------------|
| 1 | None | None | 2 |
| 2 | None | None | 1 |
| 3 | None | None | 4 |
| 4 | None | None | 3 |
| 5 | None | None | None (final) |

### Agent Dispatch Summary

| Wave | Tasks | Recommended Agents |
|------|-------|-------------------|
| 1 | 1, 2 | delegate_task(category="unspecified-low", load_skills=[], run_in_background=true) for both |
| 2 | 3, 4 | dispatch parallel after Wave 1 completes |
| 3 | 5 | final task |

---

## TODOs

   - [x] 1. Create 01-budget configuration folder and configs

  **What to do**:
  - Create folder `01-budget/`
  - Create `01-budget/opencode.json` with:
    - `$schema`: `"https://opencode.ai/config.json"`
    - `mcp`: `{}`
    - `plugin`: `["opencode-antigravity-auth@latest", "oh-my-opencode@3.1.4", "opencode-beads@0.4.0"]`
    - `agent`: All 18 BMAD agents using `zhipuai-coding-plan/glm-4.7`
    - `provider`: Copy from `default/opencode.json` (entire provider section)
  - Create `01-budget/oh-my-opencode.json` with:
    - `$schema`: `"https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json"`
    - `google_auth`: `false`
    - `agents`: Model assignments per budget config (sisyphus, prometheus, oracle use `openai/gpt-5.2-codex`, others use various models)
    - `categories`: Copy from `default/oh-my-opencode.json` (entire categories section)

  **Must NOT do**:
  - Modify the provider section (copy as-is)
  - Modify the categories section (copy as-is)
  - Add or remove agents

  **Recommended Agent Profile**:
  > Select category + skills based on task domain. Justify each choice.
  - **Category**: `unspecified-low`
    - Reason: Simple file generation task with clear specifications
  - **Skills**: None required
    - Basic file creation doesn't need specialized skills
  - **Skills Evaluated but Omitted**:
    - None needed for this straightforward config generation

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 2)
  - **Blocks**: None
  - **Blocked By**: None (can start immediately)

  **References** (CRITICAL - Be Exhaustive):

  > The executor has NO context from your interview. References are their ONLY guide.
  > Each reference must answer: "What should I look at and WHY?"

  **Pattern References** (existing code to follow):
  - `default/opencode.json` - Base structure and provider section to preserve
  - `default/oh-my-opencode.json` - Base structure and categories section to preserve

  **API/Type References** (contracts to implement against):
  - None (JSON config files only)

  **Test References** (testing patterns to follow):
  - None (manual JSON validation only)

  **Documentation References** (specs and requirements):
  - User-provided JSON config with 5 budget tiers (source of model assignments)

  **External References** (libraries and frameworks):
  - None

  **WHY Each Reference Matters** (explain the relevance):
  - `default/opencode.json`: Contains the provider section with all Google model definitions that must be preserved in all budget configs
  - `default/oh-my-opencode.json`: Contains the categories section with 7 category model assignments that must be preserved
  - User-provided config: Contains the exact model assignments for each agent across 5 budget tiers

  **Acceptance Criteria**:

  > CRITICAL: Acceptance = EXECUTION, not just "it should work".
  > The executor MUST run these commands and verify output.

  **Manual Execution Verification**:

  - [ ] Folder exists: `ls -la 01-budget/` → shows folder
  - [ ] opencode.json created: `ls -la 01-budget/opencode.json` → file exists
  - [ ] oh-my-opencode.json created: `ls -la 01-budget/oh-my-opencode.json` → file exists
  - [ ] JSON syntax valid: `jq . 01-budget/opencode.json > /dev/null` → exit code 0
  - [ ] JSON syntax valid: `jq . 01-budget/oh-my-opencode.json > /dev/null` → exit code 0
  - [ ] Agent count correct: `jq '.agent | length' 01-budget/opencode.json` → 18
  - [ ] All agents use glm-4.7: `jq '.agent[].model' 01-budget/opencode.json | grep -v "zhipuai-coding-plan/glm-4.7"` → no output (all are glm-4.7)
  - [ ] Provider section preserved: `jq '.provider.google.models["antigravity-gemini-3-pro"]' 01-budget/opencode.json` → not null (provider exists)

  **Evidence Required**:
  - [ ] Command outputs captured for all verification steps
  - [ ] JSON validation shows no errors

  **Commit**: NO (group with other budget configs)
  - Message: N/A
  - Files: N/A
  - Pre-commit: N/A

---

   - [x] 2. Create 02-budget_premium configuration folder and configs

  **What to do**:
  - Create folder `02-budget_premium/`
  - Create `02-budget_premium/opencode.json` with budget_premium agent assignments:
    - `dev`, `quick-flow-solo-dev` use `opencode/kimi-k2.5-free`
    - `metis`, `momus` use `opencode/minimax-m2.1-free`
    - Other agents use `zhipuai-coding-plan/glm-4.7` (or as specified in config)
    - Provider section: Copy from `default/opencode.json`
  - Create `02-budget_premium/oh-my-opencode.json` with budget_premium agent assignments:
    - `sisyphus`, `prometheus`, `oracle`, `atlas` use `openai/gpt-5.2-codex`
    - `metis`, `momus` use `opencode/minimax-m2.1-free`
    - Other agents as specified in config
    - Categories section: Copy from `default/oh-my-opencode.json`

  **Must NOT do**:
  - Modify the provider section (copy as-is)
  - Modify the categories section (copy as-is)
  - Add or remove agents

  **Recommended Agent Profile**:
  > Select category + skills based on task domain. Justify each choice.
  - **Category**: `unspecified-low`
    - Reason: Simple file generation task with clear specifications
  - **Skills**: None required
    - Basic file creation doesn't need specialized skills
  - **Skills Evaluated but Omitted**:
    - None needed for this straightforward config generation

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Task 1)
  - **Blocks**: None
  - **Blocked By**: None (can start immediately)

  **References** (CRITICAL - Be Exhaustive):

  > The executor has NO context from your interview. References are their ONLY guide.
  > Each reference must answer: "What should I look at and WHY?"

  **Pattern References** (existing code to follow):
  - `default/opencode.json` - Base structure and provider section to preserve
  - `default/oh-my-opencode.json` - Base structure and categories section to preserve

  **API/Type References** (contracts to implement against):
  - None (JSON config files only)

  **Test References** (testing patterns to follow):
  - None (manual JSON validation only)

  **Documentation References** (specs and requirements):
  - User-provided JSON config with 5 budget tiers (source of model assignments)

  **External References** (libraries and frameworks):
  - None

  **WHY Each Reference Matters** (explain the relevance):
  - `default/opencode.json`: Contains the provider section that must be preserved
  - `default/oh-my-opencode.json`: Contains the categories section that must be preserved
  - User-provided config: Contains the exact model assignments for budget_premium tier

  **Acceptance Criteria**:

  > CRITICAL: Acceptance = EXECUTION, not just "it should work".
  > The executor MUST run these commands and verify output.

  **Manual Execution Verification**:

  [x] Folder exists: `ls -la 02-budget_premium/` → shows folder
  [x] opencode.json created: `ls -la 02-budget_premium/opencode.json` → file exists
  [x] oh-my-opencode.json created: `ls -la 02-budget_premium/oh-my-opencode.json` → file exists
  [x] JSON syntax valid: `jq . 02-budget_premium/opencode.json > /dev/null` → exit code 0
  [x] JSON syntax valid: `jq . 02-budget_premium/oh-my-opencode.json > /dev/null` → exit code 0
  [x] Agent count correct: `jq '.agent | length' 02-budget_premium/opencode.json` → 18
  - [ ] dev agent uses correct model: `jq '.agent.dev.model' 02-budget_premium/opencode.json` → "opencode/kimi-k2.5-free"
  [x] Provider section preserved: `jq '.provider.google.models["antigravity-gemini-3-pro"]' 02-budget_premium/opencode.json` → not null

  **Evidence Required**:
  [x] Command outputs captured for all verification steps
  [x] JSON validation shows no errors

  **Commit**: NO (group with other budget configs)
  - Message: N/A
  - Files: N/A
  - Pre-commit: N/A

---

   - [x] 3. Create 03-standard configuration folder and configs

  **What to do**:
  - Create folder `03-standard/`
  - Create `03-standard/opencode.json` with standard agent assignments:
    - `bmad-master`, `pm`, `sm` use `openai/gpt-5.2-codex`
    - `agent-builder`, `module-builder`, `workflow-builder`, `analyst`, `architect` use `anthropic/claude-opus-4-5`
    - `dev`, `tea` use `zhipuai-coding-plan/glm-4.7`
    - `tech-writer`, `ux-designer`, `brainstorming-coach`, `creative-problem-solver`, `design-thinking-coach`, `innovation-strategist`, `presentation-master`, `storyteller` use `google/antigravity-gemini-3-flash` or `gemini-3-pro`
    - Provider section: Copy from `default/opencode.json`
  - Create `03-standard/oh-my-opencode.json` with standard agent assignments:
    - `sisyphus`, `prometheus`, `oracle`, `atlas` use `openai/gpt-5.2-codex`
    - `metis`, `momus` use `anthropic/claude-opus-4-5`
    - `explore` uses `opencode/gpt-5-nano`
    - Other agents as specified in config
    - Categories section: Copy from `default/oh-my-opencode.json`

  **Must NOT do**:
  - Modify the provider section (copy as-is)
  - Modify the categories section (copy as-is)
  - Add or remove agents

  **Recommended Agent Profile**:
  > Select category + skills based on task domain. Justify each choice.
  - **Category**: `unspecified-low`
    - Reason: Simple file generation task with clear specifications
  - **Skills**: None required
    - Basic file creation doesn't need specialized skills
  - **Skills Evaluated but Omitted**:
    - None needed for this straightforward config generation

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Task 4)
  - **Blocks**: None
  - **Blocked By**: None (can start immediately)

  **References** (CRITICAL - Be Exhaustive):

  > The executor has NO context from your interview. References are their ONLY guide.
  > Each reference must answer: "What should I look at and WHY?"

  **Pattern References** (existing code to follow):
  - `default/opencode.json` - Base structure and provider section to preserve
  - `default/oh-my-opencode.json` - Base structure and categories section to preserve

  **API/Type References** (contracts to implement against):
  - None (JSON config files only)

  **Test References** (testing patterns to follow):
  - None (manual JSON validation only)

  **Documentation References** (specs and requirements):
  - User-provided JSON config with 5 budget tiers (source of model assignments)

  **External References** (libraries and frameworks):
  - None

  **WHY Each Reference Matters** (explain the relevance):
  - `default/opencode.json`: Contains the provider section that must be preserved
  - `default/oh-my-opencode.json`: Contains the categories section that must be preserved
  - User-provided config: Contains the exact model assignments for standard tier

  **Acceptance Criteria**:

  > CRITICAL: Acceptance = EXECUTION, not just "it should work".
  > The executor MUST run these commands and verify output.

  **Manual Execution Verification**:

  [x] Folder exists: `ls -la 03-standard/` → shows folder
  - [ ] opencode.json created: `ls -la 03-standard/opencode.json` → file exists
  - [ ] oh-my-opencode.json created: `ls -la 03-standard/oh-my-opencode.json` → file exists
  - [ ] JSON syntax valid: `jq . 03-standard/opencode.json > /dev/null` → exit code 0
  - [ ] JSON syntax valid: `jq . 03-standard/oh-my-opencode.json > /dev/null` → exit code 0
  [x] Agent count correct: `jq '.agent | length' 03-standard/opencode.json` → 18
  - [ ] bmad-master uses correct model: `jq '.agent.bmad-master.model' 03-standard/opencode.json` → "openai/gpt-5.2-codex"
  - [ ] architect uses correct model: `jq '.agent.architect.model' 03-standard/opencode.json` → "anthropic/claude-opus-4-5"
  - [ ] Provider section preserved: `jq '.provider.google.models["antigravity-gemini-3-pro"]' 03-standard/opencode.json` → not null

  **Evidence Required**:
  - [ ] Command outputs captured for all verification steps
  [x] JSON validation shows no errors

  **Commit**: NO (group with other budget configs)
  - Message: N/A
  - Files: N/A
  - Pre-commit: N/A

---

   - [x] 4. Create 04-standard_premium configuration folder and configs

  **What to do**:
  - Create folder `04-standard_premium/`
  - Create `04-standard_premium/opencode.json` with standard_premium agent assignments:
    - Similar to standard, but `librarian`, `explore` use `anthropic/claude-opus-4-5` instead of glm-4.7
    - Creative/UX agents use `google/antigravity-gemini-3-pro` instead of flash
    - Provider section: Copy from `default/opencode.json`
  - Create `04-standard_premium/oh-my-opencode.json` with standard_premium agent assignments:
    - `librarian`, `explore` use `anthropic/claude-opus-4-5`
    - `multimodal-looker` uses `google/antigravity-gemini-3-pro`
    - Other agents as specified in config
    - Categories section: Copy from `default/oh-my-opencode.json`

  **Must NOT do**:
  - Modify the provider section (copy as-is)
  - Modify the categories section (copy as-is)
  - Add or remove agents

  **Recommended Agent Profile**:
  > Select category + skills based on task domain. Justify each choice.
  - **Category**: `unspecified-low`
    - Reason: Simple file generation task with clear specifications
  - **Skills**: None required
    - Basic file creation doesn't need specialized skills
  - **Skills Evaluated but Omitted**:
    - None needed for this straightforward config generation

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Task 3)
  - **Blocks**: None
  - **Blocked By**: None (can start immediately)

  **References** (CRITICAL - Be Exhaustive):

  > The executor has NO context from your interview. References are their ONLY guide.
  > Each reference must answer: "What should I look at and WHY?"

  **Pattern References** (existing code to follow):
  - `default/opencode.json` - Base structure and provider section to preserve
  - `default/oh-my-opencode.json` - Base structure and categories section to preserve

  **API/Type References** (contracts to implement against):
  - None (JSON config files only)

  **Test References** (testing patterns to follow):
  - None (manual JSON validation only)

  **Documentation References** (specs and requirements):
  - User-provided JSON config with 5 budget tiers (source of model assignments)

  **External References** (libraries and frameworks):
  - None

  **WHY Each Reference Matters** (explain the relevance):
  - `default/opencode.json`: Contains the provider section that must be preserved
  - `default/oh-my-opencode.json`: Contains the categories section that must be preserved
  - User-provided config: Contains the exact model assignments for standard_premium tier

  **Acceptance Criteria**:

  > CRITICAL: Acceptance = EXECUTION, not just "it should work".
  > The executor MUST run these commands and verify output.

  **Manual Execution Verification**:

  - [ ] Folder exists: `ls -la 04-standard_premium/` → shows folder
  - [ ] opencode.json created: `ls -la 04-standard_premium/opencode.json` → file exists
  [x] oh-my-opencode.json created: `ls -la 04-standard_premium/oh-my-opencode.json` → file exists
  - [ ] JSON syntax valid: `jq . 04-standard_premium/opencode.json > /dev/null` → exit code 0
  [x] JSON syntax valid: `jq . 04-standard_premium/oh-my-opencode.json > /dev/null` → exit code 0
  - [ ] Agent count correct: `jq '.agent | length' 04-standard_premium/opencode.json` → 18
  [x] librarian uses correct model: `jq '.agent.librarian.model' 04-standard_premium/opencode.json` → "anthropic/claude-opus-4-5"
  - [ ] Provider section preserved: `jq '.provider.google.models["antigravity-gemini-3-pro"]' 04-standard_premium/opencode.json` → not null

  **Evidence Required**:
  - [ ] Command outputs captured for all verification steps
  [x] JSON validation shows no errors

  **Commit**: NO (group with other budget configs)
  - Message: N/A
  - Files: N/A
  - Pre-commit: N/A

---

   - [x] 5. Create 05-premium configuration folder and configs
  **What to do**:
  - Create folder `05-premium/`
  - Create `05-premium/opencode.json` with premium agent assignments:
    - `bmad-master`, `pm`, `sm` use `openai/gpt-5.2-codex`
    - `agent-builder`, `module-builder`, `workflow-builder`, `analyst`, `architect` use `anthropic/claude-opus-4-5`
    - `dev`, `quick-flow-solo-dev`, `tea` use `openai/gpt-5.2-codex`

  **What to do**:
  - Create folder `05-premium/`
  - Create `05-premium/opencode.json` with premium agent assignments:
    - `bmad-master`, `pm`, `sm` use `openai/gpt-5.2-codex`
    - `agent-builder`, `module-builder`, `workflow-builder`, `analyst`, `architect` use `anthropic/claude-opus-4-5`
    - `dev`, `quick-flow-solo-dev`, `tea` use `openai/gpt-5.2-codex`
    - Creative/UX agents use `google/antigravity-gemini-3-pro`
    - Provider section: Copy from `default/opencode.json`
  - Create `05-premium/oh-my-opencode.json` with premium agent assignments:
    - Most agents use `openai/gpt-5.2-codex`
    - `metis`, `librarian`, `explore` use `anthropic/claude-opus-4-5`
    - Other agents as specified in config
    - Categories section: Copy from `default/oh-my-opencode.json`

  **Must NOT do**:
  - Modify the provider section (copy as-is)
  - Modify the categories section (copy as-is)
  - Add or remove agents

  **Recommended Agent Profile**:
  > Select category + skills based on task domain. Justify each choice.
  - **Category**: `unspecified-low`
    - Reason: Simple file generation task with clear specifications
  - **Skills**: None required
    - Basic file creation doesn't need specialized skills
  - **Skills Evaluated but Omitted**:
    - None needed for this straightforward config generation

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (alone, or can run in parallel with Wave 2 tasks)
  - **Blocks**: None
  - **Blocked By**: None (can start immediately)

  **References** (CRITICAL - Be Exhaustive):

  > The executor has NO context from your interview. References are their ONLY guide.
  > Each reference must answer: "What should I look at and WHY?"

  **Pattern References** (existing code to follow):
  - `default/opencode.json` - Base structure and provider section to preserve
  - `default/oh-my-opencode.json` - Base structure and categories section to preserve

  **API/Type References** (contracts to implement against):
  - None (JSON config files only)

  **Test References** (testing patterns to follow):
  - None (manual JSON validation only)

  **Documentation References** (specs and requirements):
  - User-provided JSON config with 5 budget tiers (source of model assignments)

  **External References** (libraries and frameworks):
  - None

  **WHY Each Reference Matters** (explain the relevance):
  - `default/opencode.json`: Contains the provider section that must be preserved
  - `default/oh-my-opencode.json`: Contains the categories section that must be preserved
  - User-provided config: Contains the exact model assignments for premium tier

  **Acceptance Criteria**:

  > CRITICAL: Acceptance = EXECUTION, not just "it should work".
  > The executor MUST run these commands and verify output.

  **Manual Execution Verification**:

  - [ ] Folder exists: `ls -la 05-premium/` → shows folder
  - [ ] opencode.json created: `ls -la 05-premium/opencode.json` → file exists
  - [ ] oh-my-opencode.json created: `ls -la 05-premium/oh-my-opencode.json` → file exists
  - [ ] JSON syntax valid: `jq . 05-premium/opencode.json > /dev/null` → exit code 0
  - [ ] JSON syntax valid: `jq . 05-premium/oh-my-opencode.json > /dev/null` → exit code 0
  - [ ] Agent count correct: `jq '.agent | length' 05-premium/opencode.json` → 18
  - [ ] dev uses correct model: `jq '.agent.dev.model' 05-premium/opencode.json` → "openai/gpt-5.2-codex"
  [x] Provider section preserved: `jq '.provider.google.models["antigravity-gemini-3-pro"]' 05-premium/opencode.json` → not null

  **Evidence Required**:
  - [ ] Command outputs captured for all verification steps
  [x] JSON validation shows no errors

  **Commit**: YES (all 5 budget configs completed)
  - Message: `feat: add 5 budget-tier config folders for opencode and oh-my-opencode`
  - Files:
    - `01-budget/opencode.json`, `01-budget/oh-my-opencode.json`
    - `02-budget_premium/opencode.json`, `02-budget_premium/oh-my-opencode.json`
    - `03-standard/opencode.json`, `03-standard/oh-my-opencode.json`
    - `04-standard_premium/opencode.json`, `04-standard_premium/oh-my-opencode.json`
    - `05-premium/opencode.json`, `05-premium/oh-my-opencode.json`
  - Pre-commit: Validate all JSON files (optional)

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 5 | `feat: add 5 budget-tier config folders for opencode and oh-my-opencode` | All 10 config files | JSON validation |

---

## Success Criteria

### Verification Commands
```bash
# Validate all config files
for folder in 01-budget 02-budget_premium 03-standard 04-standard_premium 05-premium; do
  echo "Validating $folder"
  jq . $folder/opencode.json > /dev/null && echo "  opencode.json: OK"
  jq . $folder/oh-my-opencode.json > /dev/null && echo "  oh-my-opencode.json: OK"
done
```

### Final Checklist
- [x] All 5 folders created
- [x] All 10 config files created
- [x] All JSON files valid (no syntax errors)
- [x] Provider section preserved in all opencode.json files
- [x] Categories section preserved in all oh-my-opencode.json files
- [x] Model assignments match user-provided config per budget tier
