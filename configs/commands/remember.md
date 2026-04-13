# /remember — Manual operativo

Cuando el usuario invoca `/remember` o cuando detectás información valiosa durante la conversación, seguí este manual para escribir o actualizar notas en el vault de Obsidian.

## Vault path

`{{VAULT_PATH}}`

## Flujo de ejecución

1. **Determiná qué guardar**: Si el usuario invocó `/remember` explícitamente, preguntale qué quiere guardar (si no lo dijo). Si se activó automáticamente, ya sabés qué información guardar.

2. **Clasificá la información** según el tipo de nota (ver sección "Templates de notas").

3. **Verificá si ya existe**: Antes de crear una nota nueva, buscá en el vault si ya hay una nota sobre el mismo tema. Si existe, actualizala en vez de crear una nueva.

4. **Escribí o actualizá la nota** siguiendo el template correspondiente.

5. **Actualizá cross-references**: Si la nota menciona un proyecto, persona o decisión que tiene su propia nota, agregá wikilinks bidireccionales.

6. **Confirmá al usuario**: Decile qué guardaste y dónde.

## Reglas de comportamiento

- NUNCA esperes al final de la sesión para guardar. Hacelo en el momento.
- NUNCA preguntes "¿querés que guarde esto?" — guardalo directamente. Solo preguntá si no estás seguro de QUÉ guardar.
- Si el usuario te corrige, actualizá la nota inmediatamente.
- Si la información contradice algo guardado anteriormente, actualizá la nota anterior y dejá un registro del cambio.
- Usá lenguaje natural, no técnico ni formal. Escribí como habla el usuario.
- Las notas son para el usuario, no para vos. Escribí para que un humano las entienda.

## Estructura de directorios

```
{{VAULT_PATH}}/
├── perfil.md                    # Quién es el usuario
├── preferencias.md              # Cómo le gusta trabajar
├── stack.md                     # Stack tecnológico
├── _meta/
│   ├── design.md                # Diseño del sistema
│   └── projectPaths.md          # Mapeo CWD -> proyecto
├── _templates/                  # Templates de notas (futuro)
├── proyectos/
│   └── <proyecto>/
│       ├── overview.md          # Resumen del proyecto
│       ├── decisiones/          # Decisiones técnicas
│       └── aprendizajes/        # Lecciones aprendidas
├── sesiones/                    # Logs de sesiones
└── rufino/                      # Notas crudas para procesar
    ├── _index.md                # Índice de notas procesadas
    ├── _processing-log.md       # Log del procesador
    └── <categoría>/             # Notas procesadas por categoría
```

## Naming de archivos

- **camelCase** para archivos: `miDecision.md`, `aprendizajeReact.md`
- **kebab-case** para carpetas de proyectos: `mi-proyecto/`
- Sin espacios, sin caracteres especiales
- Nombres descriptivos, no genéricos
- Fecha en el nombre solo si es relevante (sesiones, decisiones): `2024-01-15-sesion.md`

## Taxonomía de tags

Usá 3 ejes de tags:

### Eje 1: proyecto/
Prefijo `proyecto/` para tags de proyecto:
- `proyecto/percha`
- `proyecto/rufino`
- `proyecto/mi-api`

### Eje 2: tipo/
Prefijo `tipo/` para el tipo de información:
- `tipo/decision`
- `tipo/aprendizaje`
- `tipo/preferencia`
- `tipo/feedback`
- `tipo/bug`
- `tipo/idea`
- `tipo/referencia`

### Eje 3: tema/
Prefijo `tema/` para el tema técnico o conceptual:
- `tema/react`
- `tema/testing`
- `tema/arquitectura`
- `tema/performance`
- `tema/seguridad`
- `tema/diseño`
- `tema/workflow`

Cada nota debería tener al menos 1 tag de cada eje (cuando aplique).

## Templates de notas

### Perfil (`perfil.md`)

```markdown
# Perfil

- **Nombre:** {{USER_NAME}}
- **Rol:** <completar>
- **Background:** <completar>
- **Ubicación:** <completar>
- **Idioma preferido:** <completar>

## Sobre mí

<Descripción libre del usuario>

## Actualizado

{{DATE}}
```

### Overview de proyecto (`proyectos/<proyecto>/overview.md`)

```markdown
# <Nombre del proyecto>

## Qué es
<Una oración describiendo el proyecto>

## Stack
<Tecnologías principales>

## Estado
<En qué fase está: ideación, desarrollo, producción, mantenimiento>

## Equipo
<Quién trabaja en esto>

## Links
<Repos, deployments, docs>

## Notas
<Contexto adicional>

## Actualizado
{{DATE}}
```

### Decisión (`proyectos/<proyecto>/decisiones/<nombre>.md`)

```markdown
# <Título de la decisión>

## Contexto
<Por qué se tomó esta decisión>

## Decisión
<Qué se decidió>

## Alternativas consideradas
<Qué otras opciones había>

## Consecuencias
<Qué implica esta decisión>

## Tags
<tags relevantes>

## Fecha
{{DATE}}
```

### Aprendizaje (`proyectos/<proyecto>/aprendizajes/<nombre>.md`)

```markdown
# <Qué se aprendió>

## Contexto
<Cuándo y cómo surgió>

## El problema
<Qué estaba pasando>

## La solución
<Qué funcionó>

## Por qué funciona
<Explicación>

## Tags
<tags relevantes>

## Fecha
{{DATE}}
```

### Feedback (`preferencias.md` o nota separada)

Cuando el usuario te corrige o expresa una preferencia:

```markdown
## <Preferencia o corrección>

- **Qué:** <qué dijo el usuario>
- **Contexto:** <en qué situación>
- **Acción:** <qué debés hacer diferente>
- **Fecha:** {{DATE}}
```

### Sesión (`sesiones/<fecha>-sesion.md`)

```markdown
# Sesión {{DATE}}

## Proyecto
<En qué proyecto se trabajó>

## Resumen
<Qué se hizo en 2-3 oraciones>

## Decisiones tomadas
<Lista de decisiones>

## Pendientes
<Lo que quedó para después>

## Tags
<tags relevantes>
```

## Convenciones de wikilinks

- Usá `[[nombre-de-nota]]` para linkear notas dentro del vault
- Para linkear a una sección: `[[nombre-de-nota#sección]]`
- Para linkear con alias: `[[nombre-de-nota|texto visible]]`
- Los wikilinks deben ser bidireccionales cuando sea posible (si A linkea a B, B debería linkear a A)
- Priorizá links a: `perfil.md`, `preferencias.md`, overviews de proyectos, y decisiones

## Quick reference — checklists

### Antes de guardar una nota

- [ ] Verificaste que no existe una nota duplicada
- [ ] Elegiste el template correcto
- [ ] Usaste camelCase para el nombre del archivo
- [ ] Agregaste al menos 1 tag de cada eje (si aplica)
- [ ] Agregaste wikilinks a notas relacionadas
- [ ] El contenido es claro para un humano

### Antes de actualizar una nota existente

- [ ] Leíste la nota actual completa
- [ ] Preservaste el contenido existente
- [ ] Agregaste la nueva información (no reemplazaste)
- [ ] Actualizaste la fecha de "Actualizado"
- [ ] Si cambió algo fundamental, dejaste registro del cambio

### Antes de crear un proyecto nuevo

- [ ] Creaste la carpeta en `proyectos/`
- [ ] Creaste el `overview.md`
- [ ] Creaste subcarpetas `decisiones/` y `aprendizajes/`
- [ ] Agregaste el path en `_meta/projectPaths.md`
