# Arquitectura

El proyecto utiliza capas Presentation, Domain y Data.

- `presentation`: pantallas y widgets.
- `domain`: modelos y contratos de repositorio.
- `data`: implementaciones Drift, exportaciones y archivos.
- `core/database`: tablas, DAOs, migración y conexión SQLite.

La interfaz no accede directamente a tablas Drift; utiliza repositorios.
