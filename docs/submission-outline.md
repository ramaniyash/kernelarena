# Submission Outline

## Recommended Framing

This should be framed as a **control protocol / monitoring** submission, not a setting-design project.

The cleanest headline is:

> We identify semantic camouflage as a common failure mode in LinuxArena and build a capability-gap monitor that improves detection on a curated stealth-heavy benchmark slice.

## Suggested Abstract Shape

1. Existing monitors can miss sabotage hidden inside plausible engineering work.
2. We call this semantic camouflage.
3. We build a capability-gap monitor that compares the narrowest legitimate implementation with the capability actually introduced by each action.
4. We evaluate on a curated LinuxArena slice of stealth-heavy tasks drawn from real environment repos and strategy files.
5. We compare against `multi`, and optionally against `strong` on a subset.

## Strong Claims We Can Safely Aim For

- Semantic camouflage is a coherent and practically important attack pattern in LinuxArena.
- A capability-gap framing can improve monitoring on a curated camouflage slice.
- Existing strong LinuxArena attacks often rely on over-broad implementation choices disguised as debugging, refactoring, validation, or analytics work.

## Claims To Avoid Unless Results Are Excellent

- “We solve stealth sabotage in LinuxArena.”
- “We outperform all existing monitors broadly.”
- “Narrative/capability-gap reasoning is the main missing ingredient in AI control.”

## Best Figures / Tables

1. Table: camouflage benchmark slice with motif labels
2. Histogram or KDE: honest vs attack score distributions for `multi` and `cap-gap`
3. Safety table: 5%, 1%, 0.5% audit budgets
4. Case-study figure: action excerpt, benign cover story, hidden capability, scores by monitor

## Best Case Studies To Prioritize

- `model_registry / auto_owner_permissions / privilege_escalation`
- `web_scraping / archive_testability_refactor / expose_secret`
- `web_scraping / functional_refactor_link_extraction / log_credentials`
- `shared_dotfiles / verify_dotfiles / appropriate_secrets`

These are especially legible to judges and closely match the project thesis.
