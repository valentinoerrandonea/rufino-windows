# Rufino — Windows Installer

Este archivo contiene las instrucciones completas para instalar Rufino en Windows. Claude Code debe leer este archivo y ejecutar todos los pasos.

---

## Que es Rufino

Rufino es un sistema de memoria persistente basado en un vault de Obsidian. Incluye:

1. **Vault de Obsidian** — Carpeta estructurada donde se guardan notas, decisiones, perfiles y contexto de proyectos.
2. **Reglas de Claude Code** — Instrucciones que le dicen a Claude Code que lea y escriba en el vault automáticamente durante cada conversación.
3. **Comando /remember** — Para guardar información manualmente en el vault.
4. **Hook de Stop** — Antes de cerrar una sesión, Claude Code revisa si hay algo pendiente para guardar.
5. **Rufino Daily** — Procesador automático de notas crudas que corre todos los días a las 19:00.
6. **Prompt de procesamiento** — Instrucciones para que Claude analice, categorice y enriquezca notas.

---

## Instrucciones de instalación

Cuando el usuario diga "instalá esto", "install this", o cualquier variante, ejecutá TODOS los pasos siguientes en orden.

### Paso 0: Recopilar información del usuario

Antes de hacer cualquier cosa, preguntale al usuario estas cosas (una por una o todas juntas):

1. **"¿Dónde querés que se cree el vault de Obsidian?"**
   - Sugerí como default: `C:\Users\<username>\Documents\vault\` (reemplazá `<username>` con el nombre de usuario real detectado con `$env:USERNAME`)
   - Si el usuario acepta el default, usá ese path
   - Si el usuario da otro path, usá ese

2. **"¿Cómo te llamás?"** (para personalizar el perfil)

3. **"¿En qué idioma preferís que se escriban las notas?"** (default: español)

Guardá estos valores en variables para usarlos en los pasos siguientes:
- `$VaultPath` — Path completo al vault (sin trailing backslash)
- `$UserName` — Nombre del usuario
- `$NoteLang` — Idioma preferido (default: "español")

### Paso 1: Detectar timezone

```powershell
$Timezone = (Get-TimeZone).Id
$TimezoneDisplay = (Get-TimeZone).DisplayName
```

Mostrá al usuario: "Timezone detectada: $TimezoneDisplay"

### Paso 2: Crear el vault desde el template

Copiá toda la carpeta `vault-template/` al `$VaultPath` elegido por el usuario.

```powershell
# Crear el directorio del vault si no existe
if (-not (Test-Path $VaultPath)) {
    New-Item -ItemType Directory -Path $VaultPath -Force | Out-Null
}

# Copiar el contenido del template al vault
$TemplatePath = Join-Path $PSScriptRoot "vault-template"
Copy-Item -Path "$TemplatePath\*" -Destination $VaultPath -Recurse -Force
```

IMPORTANTE: No uses Copy-Item directamente. En su lugar, leé cada archivo del template, reemplazá los placeholders, y escribilo en el destino:

- `{{VAULT_PATH}}` -> `$VaultPath` (usá forward slashes `/` para consistencia en las notas)
- `{{USER_NAME}}` -> `$UserName`
- `{{DATE}}` -> Fecha actual en formato `YYYY-MM-DD`

Para cada archivo en `vault-template/`, leelo con `Read`, hacé los reemplazos, y escribilo con `Write` en la ubicación correspondiente dentro de `$VaultPath`.

Para los directorios vacíos (los que tienen `.gitkeep`), simplemente crealos:

```powershell
$emptyDirs = @("_templates", "proyectos", "sesiones")
foreach ($dir in $emptyDirs) {
    $dirPath = Join-Path $VaultPath $dir
    if (-not (Test-Path $dirPath)) {
        New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
    }
}
```

### Paso 3: Copiar reglas a Claude Code

Las reglas van en `$env:USERPROFILE\.claude\rules\common\`.

```powershell
$RulesDir = Join-Path $env:USERPROFILE ".claude\rules\common"
if (-not (Test-Path $RulesDir)) {
    New-Item -ItemType Directory -Path $RulesDir -Force | Out-Null
}
```

Copiá los archivos de `configs/rules/` a `$RulesDir`. Antes de copiar cada archivo, leelo y reemplazá `{{VAULT_PATH}}` con el path real del vault (usá forward slashes `/`).

Archivos a copiar:
- `configs/rules/obsidian-memory.md` -> `$RulesDir\obsidian-memory.md`
- `configs/rules/rufino.md` -> `$RulesDir\rufino.md`

### Paso 4: Copiar prompt a Claude Code

```powershell
$PromptsDir = Join-Path $env:USERPROFILE ".claude\prompts"
if (-not (Test-Path $PromptsDir)) {
    New-Item -ItemType Directory -Path $PromptsDir -Force | Out-Null
}
```

Copiá `configs/prompts/rufino-daily.md` a `$PromptsDir\rufino-daily.md`. Reemplazá `{{VAULT_PATH}}` con el path real (forward slashes).

### Paso 5: Copiar comando a Claude Code

```powershell
$CommandsDir = Join-Path $env:USERPROFILE ".claude\commands"
if (-not (Test-Path $CommandsDir)) {
    New-Item -ItemType Directory -Path $CommandsDir -Force | Out-Null
}
```

Copiá `configs/commands/remember.md` a `$CommandsDir\remember.md`. Reemplazá `{{VAULT_PATH}}` con el path real (forward slashes).

### Paso 6: Instalar hook de Stop

```powershell
$HooksDir = Join-Path $env:USERPROFILE ".claude\hooks"
if (-not (Test-Path $HooksDir)) {
    New-Item -ItemType Directory -Path $HooksDir -Force | Out-Null
}
```

Copiá `configs/hooks/obsidianMemoryCheck.ps1` a `$HooksDir\obsidianMemoryCheck.ps1`. Este archivo NO tiene placeholders, copialo tal cual.

### Paso 7: Configurar el hook en settings.json

El archivo de settings de Claude Code está en `$env:USERPROFILE\.claude\settings.json`.

IMPORTANTE: Si el archivo ya existe, MERGE la configuración. No sobrescribas el contenido existente.

Leé el archivo actual (si existe), parsealo como JSON, y agregá/actualizá la sección `hooks.Stop`:

```powershell
$SettingsPath = Join-Path $env:USERPROFILE ".claude\settings.json"

# Leer settings existentes o crear objeto vacío
if (Test-Path $SettingsPath) {
    $settings = Get-Content $SettingsPath -Raw | ConvertFrom-Json
} else {
    $settings = @{}
}
```

La configuración de hooks que debe quedar en el archivo:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "powershell.exe -ExecutionPolicy Bypass -File \"%USERPROFILE%\\.claude\\hooks\\obsidianMemoryCheck.ps1\"",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

Usá Read y Edit (o Write si no existe) para hacer el merge correctamente. Preservá todas las keys existentes.

### Paso 8: Instalar script del scheduled task

```powershell
$ScriptsDir = Join-Path $env:USERPROFILE ".claude\scripts"
if (-not (Test-Path $ScriptsDir)) {
    New-Item -ItemType Directory -Path $ScriptsDir -Force | Out-Null
}
```

Copiá `configs/scripts/rufino-scheduled.ps1` a `$ScriptsDir\rufino-scheduled.ps1`. Este archivo NO tiene placeholders.

### Paso 9: Crear el scheduled task en Windows

Detectá la hora local 19:00 del usuario y creá el task:

```powershell
$ScriptPath = Join-Path $env:USERPROFILE ".claude\scripts\rufino-scheduled.ps1"
$TaskAction = "powershell.exe -ExecutionPolicy Bypass -File '$ScriptPath'"

schtasks /create /tn "Rufino Daily" /tr $TaskAction /sc daily /st 19:00 /f
```

Si el comando falla (por ejemplo, por permisos), informale al usuario que puede crearlo manualmente:
- Abrir "Task Scheduler" de Windows
- Crear una tarea básica llamada "Rufino Daily"
- Trigger: diario a las 19:00
- Acción: iniciar programa `powershell.exe` con argumentos `-ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\scripts\rufino-scheduled.ps1"`

### Paso 10: Verificar la instalación

Verificá que todos los archivos existen:

```powershell
$filesToCheck = @(
    (Join-Path $VaultPath "perfil.md"),
    (Join-Path $VaultPath "preferencias.md"),
    (Join-Path $VaultPath "stack.md"),
    (Join-Path $VaultPath "_meta\design.md"),
    (Join-Path $VaultPath "_meta\projectPaths.md"),
    (Join-Path $VaultPath "rufino\_index.md"),
    (Join-Path $VaultPath "rufino\_processing-log.md"),
    (Join-Path $env:USERPROFILE ".claude\rules\common\obsidian-memory.md"),
    (Join-Path $env:USERPROFILE ".claude\rules\common\rufino.md"),
    (Join-Path $env:USERPROFILE ".claude\prompts\rufino-daily.md"),
    (Join-Path $env:USERPROFILE ".claude\commands\remember.md"),
    (Join-Path $env:USERPROFILE ".claude\hooks\obsidianMemoryCheck.ps1"),
    (Join-Path $env:USERPROFILE ".claude\scripts\rufino-scheduled.ps1"),
    (Join-Path $env:USERPROFILE ".claude\settings.json")
)

$allGood = $true
foreach ($file in $filesToCheck) {
    if (-not (Test-Path $file)) {
        Write-Host "FALTA: $file"
        $allGood = $false
    }
}

if ($allGood) {
    Write-Host "Todos los archivos instalados correctamente."
}
```

### Paso 11: Mensaje final

Mostrá este mensaje al usuario:

---

**Rufino instalado correctamente.**

**Que se instaló:**
- Vault de Obsidian en: `$VaultPath`
- Reglas de memoria en: `$env:USERPROFILE\.claude\rules\common\`
- Prompt de procesamiento en: `$env:USERPROFILE\.claude\prompts\`
- Comando /remember en: `$env:USERPROFILE\.claude\commands\`
- Hook de Stop en: `$env:USERPROFILE\.claude\hooks\`
- Script de tarea programada en: `$env:USERPROFILE\.claude\scripts\`
- Tarea programada "Rufino Daily" (19:00 todos los días)

**Como usarlo:**
- Claude Code va a leer y escribir en tu vault automáticamente
- Usá `/remember` para guardar algo manualmente
- Las notas crudas van en `$VaultPath/rufino/` — Rufino las procesa diariamente a las 19:00
- Para procesar notas manualmente, decile a Claude: "procesá las notas de rufino"

**Opcional pero recomendado:**
- Instalá [Obsidian](https://obsidian.md/) y abrí el vault en `$VaultPath` para visualizar tus notas con links, grafos y búsqueda.

---

## Notas técnicas

- Todos los paths en las notas de Obsidian usan forward slashes `/` para compatibilidad
- El hook de Stop usa `powershell.exe -ExecutionPolicy Bypass` para evitar problemas de política de ejecución
- El scheduled task corre como el usuario actual (no necesita permisos de administrador)
- La CLI de Claude se busca en múltiples ubicaciones posibles en Windows
- Los archivos de configuración existentes se preservan (merge, no overwrite)
