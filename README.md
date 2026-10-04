# Assignment 1 — MDL Study Team (Hermes + Telegram)

Three Hermes agents in one Telegram group. They hand work off with **@mentions**.

| Agent (profile) | Telegram bot (you create) | Role |
| --- | --- | --- |
| `coordinator` | e.g. `@mdl_coord_bot` | Talks to the human, splits work, @mentions specialists, posts the final answer |
| `researcher` | e.g. `@mdl_research_bot` | Search + summarise papers / docs |
| `coder` | e.g. `@mdl_coder_bot` | Write / explain / run small code examples |

**Shared:** one OpenRouter API key (same for all three).  
**Separate:** each bot has its own Telegram token.

---

## Repo layout

```text
assignment1/
  assignment1.md              # course brief
  README.md                   # this file
  DEFENSE_NOTES.md            # answers for the oral defense
  .gitignore
  .env.example                # placeholders only — never real secrets
  agents/
    coordinator/              # SOUL.md, AGENTS.md, config.yaml
    researcher/
    coder/
  scripts/
    setup_profiles.ps1        # create Hermes profiles + deploy configs
    start_gateways.ps1        # start all 3 Telegram gateways
    stop_gateways.ps1
  examples/
    sample_request.md         # end-to-end demo prompt
```

---

## Prerequisites

1. Hermes installed (`hermes doctor` OK). Windows home: `%LOCALAPPDATA%\hermes`
2. Free OpenRouter key + privacy toggle for free models: https://openrouter.ai/settings/privacy
3. Three Telegram bots from [@BotFather](https://t.me/BotFather) (`/newbot` × 3)
4. Your numeric Telegram user ID from [@userinfobot](https://t.me/userinfobot)
5. A Telegram **group**; add all three bots; for each bot in BotFather:  
   `/mybots` → Bot Settings → **Group Privacy → Turn off**

Suggested usernames (must end in `bot`):

- `mdl_coord_bot`
- `mdl_research_bot`
- `mdl_coder_bot`

---

## Setup

### 1. Create Hermes profiles + deploy SOUL / config

```powershell
cd assignment1\scripts
.\setup_profiles.ps1
```

This creates profiles `coordinator`, `researcher`, `coder` (cloned from default for OpenRouter settings, **without** copying Telegram tokens), then copies each agent's `SOUL.md`, `AGENTS.md`, and config snippet.

### 2. Paste secrets (you do this)

Edit **three** env files (same OpenRouter key, different bot tokens):

```text
%LOCALAPPDATA%\hermes\profiles\coordinator\.env
%LOCALAPPDATA%\hermes\profiles\researcher\.env
%LOCALAPPDATA%\hermes\profiles\coder\.env
```

Set in each:

```env
OPENROUTER_API_KEY=sk-or-v1-YOUR_KEY

TELEGRAM_BOT_TOKEN=...          # THIS bot's token only
TELEGRAM_ALLOWED_USERS=YOUR_NUMERIC_ID
```

Optional group allowlist later via Hermes docs (`allowed_chats`).

### 3. Start / reconnect gateways

On this machine Hermes often runs a **multiplexed gateway** that can serve all profiles once each has its own bot token. After pasting tokens:

```powershell
hermes gateway restart
# or, if nothing is listening:
.\start_gateways.ps1
```

If specialists never reply, run `.\start_gateways.ps1` so each profile has a live Telegram connection, and confirm BotFather **Group Privacy is OFF**.

### 4. Telegram group demo

1. Create group, add the three bots + you.
2. Turn **off** Group Privacy for each bot (BotFather).
3. In the group, send something like:

```text
@mdl_coord_bot Explain scaled dot-product attention. Have @mdl_research_bot find the original paper, and @mdl_coder_bot show a tiny PyTorch example.
```

(Or only mention the coordinator and let it @mention the others — see `examples/sample_request.md`.)

4. Expected flow:
   - Coordinator acknowledges and @mentions researchers/coder with clear subtasks
   - Researcher replies with arXiv + short summary
   - Coder replies with a small code snippet
   - Coordinator posts a short **Final answer** synthesizing both

---

## How handoff works

1. Human speaks to **Coordinator** (prefer `@coordinator_bot …`).
2. Coordinator splits into subtasks and **@mentions** `@researcher_bot` / `@coder_bot`.
3. Specialists reply **only when mentioned** (`telegram.require_mention: true`).
4. Coordinator treats specialist replies as done when each subtask has a clear answer, then posts the final synthesis.
5. Anti-loop rules are in each `SOUL.md` (no endless bot-to-bot ping-pong; max handoff rounds; silence if not addressed).

Memory lives per profile under:

```text
%LOCALAPPDATA%\hermes\profiles\<name>\memories\
```

---

## Models

All agents use OpenRouter free models (same API key). Defaults in agent configs:

| Profile | Model (free) | Why |
| --- | --- | --- |
| coordinator | `google/gemma-4-26b-a4b-it:free` | Needs planning / handoffs |
| researcher | `qwen/qwen3.8-27b:free` | Long-context summarise (if available; swap if 404) |
| coder | `google/gemma-4-26b-a4b-it:free` | Code generation |

If a free slug 404s or 429s, change with:

```powershell
hermes -p coordinator config set model.default "SOME_OTHER:free"
```

Tiny models (e.g. 2–3B) often fail at tool use and reliable @mention handoffs — see Lab 2 experience and `DEFENSE_NOTES.md`.

---

## Useful commands

```powershell
hermes profile list
hermes -p coordinator doctor
hermes -p researcher gateway
hermes -p coder gateway
hermes -p coordinator config get model
```

---

## Security

- Never commit `.env`, tokens, or keys.
- `.gitignore` already excludes them.
- If a bot token leaks: BotFather → `/revoke`.
