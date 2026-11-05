# powerbi/ · Power BI Project (PBIP) listo para abrir

Esta carpeta contiene el informe completo en formato **Power BI Project**: modelo semántico en **TMDL** e informe en **PBIR**, el formato recomendado por Microsoft para el control de versiones.

## Abrirlo

1. Haz doble clic en **`TurismoGijon.pbip`** (o *Archivo > Abrir* en Power BI Desktop).
2. El proyecto se abre sin datos (la caché no se versiona): pulsa **Inicio > Actualizar**.
3. Cuando lo pida:
   - Credenciales de `https://www.ine.es` y `https://raw.githubusercontent.com`: **Anónimo**.
   - Niveles de privacidad: **Público** para ambos orígenes.
4. La primera carga descarga los CSV completos del INE (varios MB): tarda un poco.

> Si tu versión de Power BI Desktop no abre el proyecto, activa en *Archivo > Opciones y configuración > Opciones > Características en versión preliminar* el **formato de proyecto de Power BI**, el **formato TMDL** y el **formato de informe mejorado (PBIR)**, y reinicia Desktop.

## Qué incluye

| Componente | Contenido |
|---|---|
| Consultas | 7 parámetros, 3 funciones, 3 consultas de staging, 1 consulta de calidad (sin carga) |
| Modelo | `Fact_Demanda`, `Fact_Oferta`, `Dim_Fecha` (marcada como tabla de fechas), `Dim_PuntoTuristico`, `Dim_Residencia`, `_Medidas` |
| Relaciones | 5 relaciones 1:\* con filtro de dirección única |
| Medidas | 39 medidas DAX organizadas en carpetas, con formato |
| Informe | 3 páginas (Resumen, Estacionalidad, Benchmark) con 30 visuales, tema "Gijón Cantábrico", texto alternativo y segmentadores con Gijón y 2025 preseleccionados |

## Estructura

```text
powerbi/
├── TurismoGijon.pbip                  # Punto de entrada
├── TurismoGijon.SemanticModel/
│   ├── definition/                    # Modelo en TMDL
│   │   ├── database.tmdl · model.tmdl · relationships.tmdl
│   │   ├── expressions.tmdl           # Parámetros, funciones, staging y calidad (M)
│   │   └── tables/*.tmdl              # Tablas, columnas, particiones M y medidas
│   ├── definition.pbism
│   └── .pbi/editorSettings.json       # localSettings.json y cache.abf NO se versionan
└── TurismoGijon.Report/
    ├── definition/                    # Informe en PBIR: report, pages/*/page.json, visuals/*/visual.json
    ├── StaticResources/               # Tema base y tema "Gijón Cantábrico"
    └── definition.pbir
```

## Qué se versiona y qué no

| Se versiona | No se versiona (`.gitignore`) |
|---|---|
| `*.pbip`, `definition.pbism`, `definition.pbir` | `.pbi/localSettings.json` |
| Carpetas `definition/` (TMDL y PBIR) y `StaticResources/` | `.pbi/cache.abf` (caché de datos) |
| `.pbi/editorSettings.json` | `*.pbix` (se publica en GitHub Releases) |

> El `.pbix` compilado se adjunta a cada [Release](https://github.com/GITHUB_USER/turismo-gijon-powerbi/releases) para quien sólo quiera abrir el informe.
