# Rufino - Obsidian Memory System for Claude Code (Windows)

Rufino is a persistent memory system powered by an Obsidian vault. It gives Claude Code long-term memory across conversations: it remembers who you are, what you're working on, your preferences, and your decisions.

It also includes an automated note processor that enriches raw notes with summaries, analysis, and cross-references every day.

## Prerequisites

- **Windows 10 or Windows 11**
- **VS Code** with the **Claude Code extension** installed and authenticated
- **Git** (to clone this repo)
- **Node.js 20+** — only if you install the dashboard. Check with `node -v`; install from [nodejs.org](https://nodejs.org) or `winget install OpenJS.NodeJS.LTS`

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/valentinoerrandonea/rufino-windows.git
   ```

2. Open the cloned folder in VS Code

3. Open the Claude Code extension panel

4. Type: **"instala esto"**

Claude Code reads `CLAUDE.md` and does everything automatically:
- Asks you where to create the vault and your name
- Creates the Obsidian vault with the template structure
- Installs memory rules, prompts, and commands
- Configures the Stop hook for end-of-session memory checks
- Sets up a daily scheduled task to process notes at 19:00

## What Gets Installed

| Component | Location |
|-----------|----------|
| Obsidian vault | Path you choose (default: `Documents\vault\`) |
| Memory rules | `%USERPROFILE%\.claude\rules\common\` |
| Processing prompt | `%USERPROFILE%\.claude\prompts\` |
| /remember command | `%USERPROFILE%\.claude\commands\` |
| Stop hook | `%USERPROFILE%\.claude\hooks\` |
| Scheduled task script | `%USERPROFILE%\.claude\scripts\` |
| Windows Scheduled Task | "Rufino Daily" (runs at 19:00) |
| Dashboard (optional) | `dashboard/` in this repo + Scheduled Task "RufinoDashboard" (runs at login) |

## How It Works

### Automatic Memory
Claude Code reads your profile and preferences at the start of every conversation. During the conversation, it automatically saves valuable information to the vault: decisions, learnings, preferences, project context.

### /remember Command
Type `/remember` in Claude Code to manually save something to the vault.

### Stop Hook
Before ending a session, Claude Code checks if there's anything worth saving that hasn't been written yet.

### Rufino Daily Processor
Every day at 19:00, a scheduled task runs Claude Code to process raw notes in the `rufino/` folder. It analyzes each note, assigns a **project** (e.g. `percha`, `oiko`, `general`) and a **type** (e.g. `tech`, `ideas`, `reflexiones`), then moves it to `rufino/<project>/<type>/`. Each note is enriched with a structured summary, deep analysis, cross-references, and connections to related notes.

After processing, Rufino updates four index files:
- `_index.md` — full list of processed notes organized by project and arista
- `_tags.md` — 4-axis tag index: `proyecto/<name>/<arista>`, `tema/`, `persona/`, `concepto/`
- `_pendientes.md` — action items extracted automatically with proyecto/arista, personas, deadline, and origin; supports inline syntax `#proyecto/arista @persona !deadline`
- `_people.md` — index of people mentioned in notes; each person gets their own file in `_people/<name>.md` with full mention history

## Dashboard

The dashboard is a Next.js 16 web app that serves http://localhost:3737. It runs as a user-level Windows Scheduled Task that launches at login and auto-restarts on failure.

### Features
- Capture views for notes, todos, and people
- Note list with inbox (unprocessed) + filters (search, project, tema, persona, concepto), grouped by project
- Note detail with a **structured field-by-field editor** — edit raw body, Resumen, Análisis, Implicaciones, Preguntas abiertas, Próximos pasos as separate fields. Title/tags/Context/Connections stay read-only and are preserved byte-for-byte on save.
- Todos with 3-state checkbox (`[ ]` → `[/]` → `[x]`), filters, and atomic updates to `_pendientes.md`
- People directory and project memory views
- Theme toggle (light/dark) + accent color picker

### Install via Claude Code

In VS Code with the Claude Code extension, say `instala esto` inside the repo folder. When the installer asks about the dashboard, answer yes.

### Install manually

```powershell
cd dashboard
npm install
npm run build
cd ..

powershell.exe -ExecutionPolicy Bypass -File .\configs\scripts\install-dashboard.ps1 `
    -DashboardDir "$((Get-Location).Path)\dashboard" `
    -VaultPath "<YOUR_VAULT_PATH>"
```

The install script:
1. Verifies Node 20+
2. Runs `npm install` and `npm run build` in `dashboard/`
3. Registers a Scheduled Task `RufinoDashboard` that runs at user logon and restarts on failure
4. Sets `RUFINO_VAULT_PATH` and `RUFINO_DASHBOARD_PORT` as user-scope env vars so the task inherits them
5. Starts the task and polls http://localhost:3737 to confirm

### Updating the dashboard

After editing anything under `dashboard/`:

```powershell
cd dashboard
npm run build
Stop-ScheduledTask -TaskName RufinoDashboard
Start-ScheduledTask -TaskName RufinoDashboard
```

The daemon serves the production build (`next start`), so changes need a rebuild + task restart.

### Logs

```powershell
Get-Content "$env:USERPROFILE\rufino-dashboard.log" -Tail 30 -Wait
```

### Uninstall dashboard only

```powershell
Unregister-ScheduledTask -TaskName RufinoDashboard -Confirm:$false
[Environment]::SetEnvironmentVariable("RUFINO_VAULT_PATH", $null, "User")
[Environment]::SetEnvironmentVariable("RUFINO_DASHBOARD_PORT", $null, "User")
```

## Optional: Obsidian

Install [Obsidian](https://obsidian.md/) and open the vault folder to visualize your notes with graph view, backlinks, and full-text search.

## Uninstall

1. Delete the scheduled task:
   ```powershell
   schtasks /delete /tn "Rufino Daily" /f
   ```

2. Remove Claude Code configurations:
   ```powershell
   Remove-Item "$env:USERPROFILE\.claude\rules\common\obsidian-memory.md" -Force
   Remove-Item "$env:USERPROFILE\.claude\rules\common\rufino.md" -Force
   Remove-Item "$env:USERPROFILE\.claude\prompts\rufino-daily.md" -Force
   Remove-Item "$env:USERPROFILE\.claude\commands\remember.md" -Force
   Remove-Item "$env:USERPROFILE\.claude\hooks\obsidianMemoryCheck.ps1" -Force
   Remove-Item "$env:USERPROFILE\.claude\scripts\rufino-scheduled.ps1" -Force
   ```

3. Manually remove the `hooks.Stop` entry from `%USERPROFILE%\.claude\settings.json`

4. The vault folder is yours to keep or delete.

## License

MIT
