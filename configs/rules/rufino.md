# Rufino — Note Vault

El usuario tiene una carpeta `rufino/` en su vault de Obsidian donde escribe notas crudas que se procesan automáticamente.

## Cuándo activar

Si el usuario menciona "rufino", "mis notas", o pregunta sobre algo que no es un proyecto de código, buscá en `rufino/`.

## Cómo buscar

1. Leé primero `{{VAULT_PATH}}/rufino/_index.md` — tiene el mapa completo de notas procesadas con categorías, tags y resúmenes.
2. Si necesitás más detalle, leé las notas específicas dentro de las subcarpetas de `rufino/`.
3. Las notas sin procesar (en la raíz de `rufino/`) son crudas — podés leerlas pero no tienen augmentation todavía.

## Qué podés hacer

- Buscar notas por tema, tag, categoría o contenido
- Resumir notas de un período
- Cruzar conexiones entre notas
- Ejecutar el procesamiento manualmente si el usuario lo pide (usá el prompt de `~/.claude/prompts/rufino-daily.md`)
- Expandir o actualizar la augmentation de una nota específica

## Path

`{{VAULT_PATH}}/rufino/`
