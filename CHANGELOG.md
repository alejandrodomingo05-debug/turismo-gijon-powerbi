# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y [versionado semántico](https://semver.org/lang/es/).

## [Sin publicar]

### Pendiente
- Capturas reales e insights con los datos actualizados.
- Publicación en el servicio de Power BI con actualización programada.

## [0.3.0] · 2026-11-09

### Añadido
- Guía de uso (`docs/GUIA_DE_USO.md`): requisitos, descarga, primera apertura, recorrido por las tres páginas, tareas habituales, solución de problemas y glosario.
- Acceso directo a la guía de uso desde el README.

## [0.2.0] · 2026-11-05

### Añadido
- Proyecto Power BI listo para abrir (`powerbi/TurismoGijon.pbip`): modelo en TMDL con 5 relaciones y 39 medidas, informe en PBIR con 3 páginas y 30 visuales.
- Consulta `stg_RefPuntos` con copia incrustada de respaldo si el repositorio no es accesible.
- Medidas de interfaz: etiquetas de variación de viajeros, estancia y ocupación, mes pico y `Estancia Media AA`.

### Cambiado
- `Dim_PuntoTuristico` ya no accede a la web directamente (evita el error Formula.Firewall).

## [0.1.0] · 2026-11-05

### Añadido
- Guía de desarrollo completa por fases: fuentes, ETL, modelo, DAX, diseño y repositorio.
- Consultas de Power Query (un fichero por consulta): parámetros, funciones, staging, modelo y calidad.
- Script de medidas DAX para la Vista de consultas DAX y columna calculada `Con Datos`.
- Tema de informe "Gijón Cantábrico" validado contra el esquema oficial de Microsoft.
- Wireframe de la página Resumen, diccionario de datos y CSV de referencia de destinos.
- Script de descarga y validación de datos del INE.
