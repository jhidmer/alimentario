# Actualización SDD: Registro Rápido De Alimentos

## Decisión UX

Durante el registro de desayuno, almuerzo, cena o entre comidas, el usuario podrá crear un alimento sin abandonar el formulario actual.

## Flujo

```text
Registrar comida
↓
Buscar alimento
↓
+ Agregar alimento nuevo
↓
Nombre y categoría
↓
Guardar
↓
Seleccionar automáticamente el alimento
```

## Reglas

- El nombre será obligatorio.
- La categoría será obligatoria.
- Se usará `normalized_name` para evitar duplicados.
- El alta se realizará en un panel inferior.
- La fecha, hora y alimentos ya seleccionados se conservarán.
- El alimento creado aparecerá inmediatamente en la selección.
- No será necesario navegar a Configuración.

## Catálogo

Los alimentos se mostrarán agrupados por frecuentes, recientes, resultados de búsqueda y categorías. Las categorías predeterminadas y personalizadas se almacenarán localmente en SQLite mediante Drift.

## Catálogo inicial

La primera apertura precarga alimentos habituales de Perú y Latinoamérica en frutas, verduras, carnes, pescados, lácteos, huevos, cereales, tubérculos, legumbres, dulces, bebidas, grasas y salsas, comida preparada y snacks. El seed es idempotente: no duplica alimentos personalizados ni registros existentes.

## Preparación Para Google Play

La publicación en Google Play será una fase posterior y no forma parte de la generación habitual de APK de prueba.

### Requisitos técnicos

- `applicationId`: `com.jhidmer.diarioalimentario`.
- Mantener `targetSdkVersion` igual o superior al mínimo vigente de Google Play.
- Publicar un Android App Bundle (`.aab`) en lugar de un APK debug.
- Configurar firma release y Play App Signing.
- Definir un `applicationId` definitivo antes de la primera publicación.
- Verificar compatibilidad de 64 bits.
- Probar instalación limpia y actualización sobre versiones anteriores.

### Requisitos legales y de privacidad

- Publicar una política de privacidad en una URL pública y permanente.
- Explicar que los datos se almacenan localmente.
- Explicar el uso de fotografías, cámara y almacenamiento privado.
- Declarar que no existe servidor, analítica remota ni publicidad.
- Documentar eliminación de datos y restauración de copias.
- Completar el formulario Data safety de Play Console.

### Requisitos De Salud

La aplicación registra síntomas y reacciones, por lo que deberá completar la declaración de aplicaciones de salud de Play Console.

La descripción pública deberá indicar:

> Diario Alimentario no es un dispositivo médico y no diagnostica, trata, cura ni previene ninguna enfermedad. Las asociaciones mostradas son coincidencias estadísticas y no sustituyen la evaluación de un profesional de la salud.

La aplicación no deberá afirmar causalidad ni emitir diagnósticos.

### Ficha De La Tienda

Antes de publicar se prepararán:

- nombre y descripción corta;
- descripción completa;
- icono de 512 x 512 px;
- imagen destacada de 1024 x 500 px;
- capturas de pantalla Android;
- clasificación de contenido IARC;
- categoría de la aplicación;
- correo de contacto;
- política de privacidad;
- países de distribución.

### Pruebas De Publicación

Para una cuenta personal nueva se planificará una prueba cerrada con al menos 12 testers durante 14 días continuos, de acuerdo con los requisitos vigentes de Google Play.

La lista de pruebas incluirá:

- Android 11 o superior;
- distintos tamaños de pantalla;
- instalación limpia;
- actualización de versión;
- cámara y fotografías;
- backup y restauración;
- exportación CSV y PDF;
- eliminación total;
- tema claro y oscuro;
- funcionamiento sin Internet.

### Orden De Implementación Posterior

1. Definir `applicationId` definitivo.
2. Configurar firma release.
3. Crear política de privacidad pública.
4. Completar Data safety y declaración de salud.
5. Generar Android App Bundle release.
6. Crear ficha de Play Store.
7. Ejecutar prueba cerrada.
8. Corregir incidencias de testers.
9. Solicitar acceso a producción.
10. Publicar la primera versión.

La generación de APK o AAB no se ejecutará automáticamente durante el desarrollo. Solo se realizará cuando sea indicada explícitamente.

## Referencia De Aplicaciones Similares

La revisión de mySymptoms Food Diary y Bearable muestra patrones de UX que pueden mejorar Diario Alimentario sin cambiar su principio offline-first:

- registro de comidas y síntomas en pocos toques;
- alimentos frecuentes y recientes visibles al iniciar cada registro;
- comidas habituales reutilizables;
- personalización de alimentos, síntomas y factores de contexto;
- intensidad y duración de síntomas;
- informes CSV/PDF para compartir con profesionales;
- análisis temporal con advertencia de no causalidad;
- indicadores de confianza o cantidad mínima de registros antes de mostrar una asociación;
- respaldo y eliminación controlados por el usuario;
- recordatorios locales opcionales en una fase posterior.

Estas referencias no implican copiar funcionalidades, diseño ni contenido de terceros. Se utilizarán únicamente como criterios de mejora de experiencia.

## Hoja De Ruta De Mejoras

Las siguientes mejoras se implementarán en este orden, siempre manteniendo funcionamiento offline y almacenamiento local:

1. Comidas habituales reutilizables.
2. Cantidad y unidad por alimento.
3. Recordatorios locales.
4. Pantalla de detalle completa.
5. Confianza estadística y cantidad mínima de registros.
6. Gráficos de tendencias.
7. Sueño, estrés, medicamentos y suplementos.
8. PIN o biometría local.
9. Escáner de código de barras como función posterior.

### Mejora 01: Comidas Habituales

El usuario podrá guardar una combinación de alimentos como comida habitual, por ejemplo:

```text
Desayuno habitual: Pan + Huevo + Café
```

Al seleccionar una comida habitual, sus alimentos se cargarán automáticamente en el formulario actual. Las comidas habituales se almacenarán en tablas locales `meal_templates` y `meal_template_foods`, sin reemplazar los registros históricos.

Reglas:

- El nombre de la comida habitual será obligatorio.
- Debe contener al menos un alimento.
- Podrá utilizarse para desayuno, almuerzo, cena o snack.
- Podrá desactivarse sin eliminar comidas históricas.
- Los cambios posteriores no modificarán comidas ya registradas.

Estado: implementada la persistencia local, selección desde el formulario, guardado de combinaciones habituales y cantidad/unidad opcionales por alimento.

### Mejora 03: Recordatorios Locales

El usuario podrá activar un recordatorio diario y seleccionar la hora. Las notificaciones se programarán localmente, sin cuenta, servidor ni conexión a Internet. El permiso podrá rechazarse sin afectar el registro de comidas.

### Mejora 04: Detalle De Registros

Cada comida y reacción tendrá una vista de detalle accesible desde Hoy e Historial. La vista mostrará toda la información guardada y mantendrá acciones de edición y eliminación.

Estado: implementada para comidas y reacciones, incluyendo fotografías de reacciones.

### Mejora 07: Sueño Y Estrés

El usuario podrá registrar opcionalmente minutos dormidos, calidad del sueño, nivel de estrés y notas del día. Estos datos se almacenarán localmente y podrán relacionarse con tendencias futuras, sin afirmar causalidad.

Estado: persistencia local y registro diario implementados desde Hoy.

### Mejora 08: Medicamentos Y Suplementos

El contexto diario permite registrar medicamentos y suplementos con nombre, dosis, unidad y notas opcionales. Estos registros son locales y descriptivos; la aplicación no recomienda dosis ni tratamientos.

Estado: implementado el registro y eliminación diaria; la integración con estadísticas queda para una etapa posterior.

### Mejora 10: Hidratación Diaria

El usuario podrá registrar varias tomas de agua por día en mililitros, agregar notas y eliminar tomas. Se mostrará el total diario en el contexto y los datos permanecerán locales.

Estado: implementado el registro, total diario y eliminación; la integración con estadísticas queda para una etapa posterior.

### Mejora 11: Estado De Ánimo

El contexto diario permite registrar una escala de ánimo de 1 a 5 y notas opcionales. El registro es local y descriptivo; no representa una evaluación psicológica ni médica.

Estado: implementado el registro y edición diaria; la integración con tendencias queda para una etapa posterior.

### Mejora 09: Actividad Física

El contexto diario permite registrar caminar, correr, bicicleta, gimnasio, deporte, estiramiento u otra actividad, junto con duración, intensidad y notas opcionales.

Estado: implementado el registro y eliminación diaria; la integración con estadísticas queda para una etapa posterior.

### Mejora 05: Confianza Estadística

Los patrones mostrarán siempre el tamaño de muestra y no solo el porcentaje. Se aplicarán estas etiquetas orientativas:

- menos de 5 consumos: `Datos insuficientes`;
- 5 a 9: `Confianza baja`;
- 10 a 19: `Confianza moderada`;
- 20 o más: `Muestra más estable`.

Estas etiquetas no representan una validación médica ni causalidad. Sirven para evitar que el usuario interprete porcentajes pequeños como conclusiones firmes.

### Mejora 06: Gráficos De Tendencias

Estadísticas mostrará una vista diaria de comidas y reacciones para el periodo elegido. La vista será descriptiva, no diagnóstica, y no afirmará causalidad.

Estado: implementada con barras diarias para los últimos 31 días del periodo seleccionado.

## Mejoras UX Implementadas

- El backup permite seleccionar la carpeta de destino y muestra la ruta generada.
- El tema claro/oscuro se persiste y se aplica inmediatamente.
- Hoy permite editar y eliminar comidas desde cada registro.
- La creación rápida de alimentos conserva la comida en curso y selecciona el alimento nuevo automáticamente.
