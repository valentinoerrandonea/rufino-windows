# Vault Design — Sistema de memoria

Este documento describe el diseño del vault de Obsidian usado como sistema de memoria persistente para Claude Code.

## Propósito

Darle a Claude Code memoria a largo plazo entre conversaciones. Cada vez que se inicia una sesión, Claude lee el perfil del usuario, sus preferencias y el contexto del proyecto actual. Durante la sesión, guarda información valiosa automáticamente.

## Estructura

```
{{VAULT_PATH}}/
├── perfil.md              # Identidad del usuario
├── preferencias.md        # Cómo le gusta trabajar
├── stack.md               # Stack tecnológico
├── _meta/                 # Metadatos del sistema
│   ├── design.md          # Este archivo
│   └── projectPaths.md    # Mapeo directorio -> proyecto
├── _templates/            # Templates de notas (futuro)
├── proyectos/             # Un subdirectorio por proyecto
│   └── <proyecto>/
│       ├── overview.md
│       ├── decisiones/
│       └── aprendizajes/
├── sesiones/              # Logs de sesiones de trabajo
└── rufino/                # Notas crudas + procesadas
    ├── _index.md
    ├── _processing-log.md
    └── <categoría>/       # Notas procesadas por categoría
```

## Convenciones

- **Archivos**: camelCase (`miDecision.md`)
- **Carpetas de proyectos**: kebab-case (`mi-proyecto/`)
- **Tags**: 3 ejes — `proyecto/`, `tipo/`, `tema/`
- **Links**: Wikilinks de Obsidian `[[nota]]`
- **Idioma**: El idioma preferido del usuario
- **Paths en notas**: Forward slashes para consistencia

## Flujo de datos

1. **Inicio de sesión**: Claude lee `perfil.md`, `preferencias.md`, y el overview del proyecto actual
2. **Durante sesión**: Claude escribe notas automáticamente via `/remember`
3. **Fin de sesión**: Hook verifica que no quede nada pendiente
4. **Diario 19:00**: Rufino procesa notas crudas en `rufino/`

## Procesamiento de notas (Rufino)

Las notas crudas se dejan en `rufino/`. El procesador diario:
1. Las lee y analiza
2. Las categoriza
3. Les agrega augmentation (resumen, análisis, implicaciones)
4. Las mueve a subcarpetas por categoría
5. Actualiza el índice y el log
