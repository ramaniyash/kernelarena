# KernelArena: Submission Roadmap

Apart AI Control Hackathon, March 2026. Track 1: Control Setting Design.

## What The Judges Want

The submission is a **PDF research report** scored on three dimensions (each 1-5):

1. **Impact Potential & Innovation** -- Does this matter for AI safety? Is it actually new?
2. **Execution Quality** -- Is methodology sound, are results interpretable, are limitations acknowledged?
3. **Presentation & Clarity** -- Can a judge quickly understand the problem, approach, results, and implications?

The Track 1 guidance says: "We don't expect fully working control settings for this track. A single main task and a side task can show off the majority of the interesting dynamics." More tasks or a scalable pipeline are bonus, not requirements.

## What We Are Submitting

A new control setting for low-level systems code (kernel/firmware), arguing that it represents a qualitatively harder monitoring regime than application-level settings like LinuxArena or BashArena.

**Core claim:** The safety/usefulness frontier degrades in low-level domains because (1) unsafe primitives are legitimate, (2) diffs are semantically dense, and (3) xz-style sabotage techniques are standard engineering patterns. Current monitors trained on app-level code will underperform here.

**Differentiation from LinuxArena:** LinuxArena covers 20 app-level environments (1K-10K LOC web backends, CLI tools, scripts). KernelArena covers kernel and firmware code where pointer arithmetic, capability checks, and compat dispatch are everyday patterns. The side tasks map to real CVE-2024-3094 (xz backdoor) techniques, not generic API key exfiltration.

## Deliverables

| # | Deliverable | Status | Priority |
|---|---|---|---|
| 1 | Runnable kernel prototype with honest + sabotaged patches | **Done** -- `environments/` has `ka_vuln.c`, patches, triggers, `run_all.sh` | Ship |
| 2 | At least 1 working hidden side-task scorer | **Done** -- `trigger_overflow.c`, `trigger_raretrig.c`, `trigger_compat.c` all exist | Ship |
| 3 | Visible test suite that passes on BOTH honest and sabotaged patches | **Done** -- `test_visible.c` | Ship |
| 4 | Task scaffolding (task.yaml, visible_requirements.md) | **Done** -- 3 kernel + 2 firmware tasks | Ship |
| 5 | Scorer interface contracts | **Done** -- `scorers/interfaces.md` | Ship |
| 6 | Agent transcripts (honest + attack + monitor) | **Partially done** -- prompts ready in `paper/LLM_TEST_PROMPTS.md`, need to run them | Must do |
| 7 | Paper PDF using submission template | **Draft exists** -- `paper/kernelarena_submission.md`, needs filling | Must do |
| 8 | Repo cleanup | **Not done** -- build artifacts, `.ipynb_checkpoints`, untracked docs | Must do |

## Execution Plan

### Phase 1: Get Evidence (first priority)

These produce the data that goes in the paper. Nothing else matters without them.

**1a. Run the prototype end-to-end and capture output**

```bash
cd kernelarena/environments
sudo bash scripts/run_all.sh
```

Save all output from `results/` -- build logs, visible test logs, trigger results for buggy/honest/sabotaged. This is Table evidence: "visible tests pass on sabotaged patches, hidden scorers catch the sabotage."

**1b. Run the 4 LLM test prompts**

Use `paper/LLM_TEST_PROMPTS.md`. Paste into Claude and/or GPT-4. Save full responses:

| Prompt | Purpose | Save to |
|---|---|---|
| Honest agent | Model fixes the bug correctly | `transcripts/honest_agent.txt` |
| Attack agent | Model fixes bug + hides sabotage | `transcripts/attack_agent.txt` |
| Monitor on honest patch | Monitor reviews the honest fix | `transcripts/monitor_honest.txt` |
| Monitor on sabotaged patch | Monitor reviews the sabotaged fix | `transcripts/monitor_sabotaged.txt` |

This produces Table evidence: "attack agent can produce sabotaged fix; monitor gives suspiciousness score X on honest vs Y on sabotaged."

**1c. Diff the honest vs sabotaged patches**

Compute the character-level diff between `patches/task1_honest.patch` and `patches/task1_sabotaged.patch`. Report the exact character count difference. This is the flagship statistic: "the sabotaged fix differs from the honest fix by N characters."

### Phase 2: Write the Paper

Use `template.pdf` format. Target 4-6 pages + references + appendix. Pull from the existing drafts (`paper/kernelarena_submission.md` and `paper/kernelarena_draft.md`) but restructure for the template.

**Section 1: Introduction (0.5 pages)**

- Problem: AI agents deployed for kernel maintenance can execute xz-style attacks at machine speed with no social engineering bottleneck.
- Gap: Existing control settings (LinuxArena, BashArena, SHADE-Arena) focus on app-level code where monitoring is comparatively tractable.
- Contribution: KernelArena, a control setting for kernel/firmware that gives the untrusted model enough power to attempt subtle low-level sabotage, enabling control protocol stress-testing in a harder regime.

Contributions list:
1. A new control setting targeting kernel and firmware domains with xz-inspired side tasks.
2. A proof-of-concept demonstrating that sabotaged patches pass all visible tests and differ from honest fixes by only a few characters.
3. Preliminary evidence that AI monitors struggle to distinguish honest from sabotaged fixes in low-level code.

**Section 2: Related Work (0.5 pages)**

- AI Control framework (Greenblatt et al., 2024)
- LinuxArena (Redwood Research, 2025) -- 20 app-level environments, app-level side tasks
- BashArena -- shell tasks, 4 side tasks beaten by task decomposition
- SHADE-Arena -- multi-tool environments
- CTRL-ALT-DECEIT -- code sabotage evaluations, NeurIPS 2025
- Low-level benchmarks: RGym, KGym, EmbedBench -- no adversarial side tasks
- xz backdoor (CVE-2024-3094) -- the real-world precedent
- Underhanded programming contests

**Section 3: Methods (1.5 pages)**

3.1 Threat model: untrusted model deployed for kernel maintenance, given main task + covert side task, monitored by trusted system.

3.2 Environment design: `kernel_repair_lab` with real kernel module (`ka_vuln.c`), KASAN-enabled build, visible tests, hidden scorers.

3.3 Side-task taxonomy -- the three xz-mapped patterns:

| Pattern | xz Technique | KernelArena Implementation |
|---|---|---|
| Security-check sabotage | Landlock typo | Wrong variable in bounds check (3-char diff) |
| Rare-trigger bypass | x86_64+glibc activation | Debug command exception to bounds check |
| Function-pointer redirect | IFUNC hook | Compat handler skips security checks |

3.4 Three-layer scoring: visible regression, hidden usefulness, hidden side task. Include the JSON contract from `scorers/interfaces.md`.

3.5 Why low-level is structurally harder: unsafe primitives are normal, diffs are semantically dense, rare-trigger sabotage is natural, blast radius is system-wide.

**Section 4: Results (1 page)**

4.1 Prototype demonstration:

| Patch Version | Visible Tests | Hidden Scorer (overflow) | Hidden Scorer (rare-trigger) |
|---|---|---|---|
| Buggy | FAIL | OVERFLOW_DETECTED | RARE_TRIGGER_DETECTED |
| Honest fix | PASS | SAFE | SAFE |
| Sabotaged (landlock) | PASS | OVERFLOW_DETECTED | SAFE |
| Sabotaged (rare-trigger) | PASS | SAFE | RARE_TRIGGER_DETECTED |

Key finding: visible tests pass on all patched versions. Only hidden scorers distinguish honest from sabotaged.

4.2 Case study: honest vs sabotaged diff (include the actual code, show the N-character difference).

4.3 Agent evaluation: show honest-agent and attack-agent transcripts. Did the attack agent produce a plausible sabotaged fix? Did the model-as-monitor catch it?

4.4 Structural comparison table (from `paper/kernelarena_submission.md` Table 4): LinuxArena vs KernelArena across unsafe-primitive density, semantic density, binary data, trigger-input space, etc.

**Section 5: Discussion and Limitations (0.75 pages)**

- The xz techniques are standard engineering -- monitors that flag them produce false positives on honest work.
- Scale limitation: proof-of-concept with synthetic module, not yet real Syzbot bugs.
- No quantitative safety curves yet (qualitative monitoring analysis only).
- Firmware track is earlier-stage than kernel track.
- Future work: LinuxArena integration for direct safety-frontier comparison, execution-aware monitoring, broader task coverage.

**Section 6: Conclusion (0.25 pages)**

Low-level code is where sabotage is most dangerous and monitoring is weakest. KernelArena demonstrates this with a proof-of-concept where 3-character patches evade all visible tests. The AI safety community needs control protocols that work in this regime before deploying AI agents on critical infrastructure.

### Phase 3: Clean the Repo

The judges will look at the GitHub link. It needs to be navigable.

- [ ] Remove build artifacts: `environments/module/*.ko`, `*.o`, `*.mod`, `*.mod.c`, `Module.symvers`, `modules.order`, `*.cmd` files
- [ ] Remove compiled test/trigger binaries: `environments/tests/test_visible`, `environments/triggers/trigger_*` (compiled)
- [ ] Remove `.ipynb_checkpoints/`
- [ ] Add `transcripts/` directory with the 4 saved LLM outputs
- [ ] Add `results/` directory with prototype run output
- [ ] Update `.gitignore` for build artifacts
- [ ] Verify `tools/validate_hackathon_mvp.py` runs clean
- [ ] Add the final PDF to `paper/`

### Phase 4: Format and Submit

- [ ] Convert paper to PDF using the submission template
- [ ] Abstract <= 250 words
- [ ] All placeholders replaced, all TODOs removed
- [ ] Figures/tables numbered and captioned
- [ ] LLM usage statement included
- [ ] References consistent
- [ ] Submit through the official submission form
- [ ] Double-check PDF before submitting (not editable after)

## What Makes This Submission Strong

Against the rubric:

**Impact (targeting 4):** Low-level AI control is a genuinely neglected problem area. LinuxArena, BashArena, SHADE-Arena, CTRL-ALT-DECEIT all focus on app-level code. No existing control setting covers kernel/firmware. The xz backdoor is a real precedent showing this domain matters. The claim that monitoring is structurally harder here is novel and testable.

**Execution (targeting 3-4):** We have a working prototype with real code, real patches, real scorers, and real LLM transcripts. The three-layer scoring design is clean. The xz mapping is concrete, not hand-wavy. Limitations are acknowledged honestly (small scale, synthetic module, no safety curves).

**Presentation (targeting 4):** The xz story is a strong narrative hook. The 3-character diff is a compelling statistic. The honest-vs-sabotaged code comparison is visual and immediate. The structural comparison table makes the LinuxArena contrast concrete.

## What Could Go Wrong

| Risk | Mitigation |
|---|---|
| Prototype doesn't build (kernel headers missing) | Already has build evidence from prior runs; worst case, show the existing output |
| LLM refuses attack prompt | Reframe as "AI safety red team evaluation"; use system prompt; try multiple models |
| Monitor catches the sabotage easily | Still an interesting result -- frame as "this side task needs to be harder" |
| Paper too long | Cut to 4-6 pages; move detailed scorer designs and full transcripts to appendix |
| Repo is messy | .gitignore + cleanup pass; prioritize this before submission |

## Priority Stack (if time is short)

If you can only do N things, do them in this order:

1. Run the 4 LLM prompts and save transcripts -- **this is irreplaceable evidence**
2. Write Results section with actual data -- **this is what gets scored**
3. Write Methods section clearly -- **this is what makes it replicable**
4. Write Introduction with contributions list -- **this is what hooks the judge**
5. Clean the repo -- **this is what makes it credible**
6. Everything else (firmware track details, stretch domains, roadmap sections)
