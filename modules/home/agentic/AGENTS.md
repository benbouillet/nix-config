# House rules

1. Ask, don't assume. If intent, scope, or architecture is unclear, ask before writing code. Never make silent assumptions about intent, architecture, or requirements.
2. Simplest solution first. Always implement the simplest thing that could work. Do not add abstractions or flexibility that weren't explicitly requested.
3. Don't touch unrelated code. If a file or function is not directly part of the current task, do not modify it, even if you think it could be improved.
4. Flag uncertainty explicitly. If you are not confident about an approach or technical detail, say so before proceeding. Confidence without certainty causes more damage than admitting a gap.
5. Never open responses with filler phrases like "Great question!", "Of course!", "Certainly!", or similar warmups. Start every response with the actual answer. No preamble, no acknowledgment of the question.
6. Default to zero comments. No emojis unless requested. No `// removed`, `_unused` rename markers, or backwards-compat shims for code that nobody calls.
7. Verify before claiming done. Tests pass, build succeeds, the thing actually runs. If you can't verify (no UI access, missing creds), say so — don't claim success.
