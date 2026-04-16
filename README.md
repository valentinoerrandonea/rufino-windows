# Rufino - Obsidian Memory System for Claude Code (Windows)

Rufino is a persistent memory system powered by an Obsidian vault. It gives Claude Code long-term memory across conversations: it remembers who you are, what you're working on, your preferences, and your decisions.

It also includes an automated note processor that enriches raw notes with summaries, analysis, and cross-references every day.

## Prerequisites

- **Windows 10 or Windows 11**
- **VS Code** with the **Claude Code extension** installed and authenticated
- **Git** (to clone this repo)

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
- `_index.md` — full list of processed notes organized by project
- `_tags.md` — tag index grouping notes by `tema/` tag and by project
- `_pendientes.md` — action items and TODOs extracted automatically from processed notes; mark items `[x]` when done
- `_people.md` — directory of people mentioned in your notes, with their relationship and associated projects

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
