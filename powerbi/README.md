# powerbi/ · Power BI Project (PBIP)

Esta carpeta contiene el informe en formato **Power BI Project**, el formato recomendado por Microsoft para el control de versiones.

## Cómo generarlo

1. Construye el informe siguiendo [`docs/GUIA_DESARROLLO.md`](../docs/GUIA_DESARROLLO.md).
2. *Archivo > Guardar como > Archivos de proyecto de Power BI (\*.pbip)* → guárdalo aquí como `TurismoGijon`.
3. Haz *commit* de los ficheros generados.

## Estructura esperada

```text
powerbi/
├── TurismoGijon.pbip                  # Punto de entrada: ábrelo con Power BI Desktop
├── TurismoGijon.SemanticModel/
│   ├── definition/                    # Modelo en TMDL: tablas, relaciones, medidas, expresiones M
│   ├── definition.pbism
│   └── .pbi/                          # localSettings.json y cache.abf → NO se versionan
└── TurismoGijon.Report/
    ├── definition/                    # Informe en PBIR: páginas y visuales en JSON
    └── definition.pbir
```

## Qué se versiona y qué no

| Se versiona | No se versiona (`.gitignore`) |
|---|---|
| `*.pbip`, `definition.pbism`, `definition.pbir` | `.pbi/localSettings.json` |
| Carpetas `definition/` (TMDL y PBIR) | `.pbi/cache.abf` (caché de datos) |
| Recursos del informe (temas, imágenes) | `*.pbix` (se publica en GitHub Releases) |

> El `.pbix` compilado se adjunta a cada [Release](https://github.com/GITHUB_USER/turismo-gijon-powerbi/releases) para quien sólo quiera abrir el informe.
