# Backup

El formato `.diarybackup` es un ZIP con:

```text
database.sqlite
metadata.json
photos/
```

Antes de restaurar se crea una copia local `*.before_restore`. La aplicación debe reiniciarse después de restaurar para volver a abrir la conexión SQLite con el archivo reemplazado.
