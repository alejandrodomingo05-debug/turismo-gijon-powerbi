# Diccionario de datos

Modelo semántico del dashboard de turismo hotelero en Gijón. Las columnas marcadas como **oculta** no se muestran en la vista de informe: se consumen a través de medidas o se usan sólo para ordenar y relacionar.

## Fact_Demanda

Hechos de demanda hotelera · grano **mes × destino × residencia** · origen INE EOH, tabla 2078.

| Columna | Tipo | Descripción | Visibilidad |
|---|---|---|---|
| `Fecha` | Fecha | Primer día del mes de referencia | Oculta (FK → `Dim_Fecha`) |
| `PuntoKey` | Entero | Clave del destino | Oculta (FK → `Dim_PuntoTuristico`) |
| `ResidenciaKey` | Entero | Clave del mercado emisor | Oculta (FK → `Dim_Residencia`) |
| `Viajeros` | Entero | Viajeros entrados en establecimientos hoteleros | Oculta (medida `Viajeros`) |
| `Pernoctaciones` | Entero | Noches que pasan los viajeros en el establecimiento | Oculta (medida `Pernoctaciones`) |

## Fact_Oferta

Instantánea mensual de oferta y ocupación · grano **mes × destino** · origen INE EOH, tabla 2076.

| Columna | Tipo | Descripción | Agregación correcta |
|---|---|---|---|
| `Fecha` | Fecha | Primer día del mes | FK → `Dim_Fecha` |
| `PuntoKey` | Entero | Clave del destino | FK → `Dim_PuntoTuristico` |
| `Establecimientos` | Entero | Establecimientos abiertos estimados | Suma entre destinos, media entre meses |
| `Habitaciones` | Entero | Habitaciones estimadas | Suma entre destinos, media entre meses |
| `Plazas` | Entero | Plazas estimadas (incluye camas supletorias) | Suma entre destinos, media entre meses |
| `Personal Empleado` | Entero | Personal empleado en el sector hotelero | Suma entre destinos, media entre meses |
| `Plazas Dia` | Entero | Plazas × días del mes (capacidad del periodo) | Aditiva · peso de ponderación |
| `Habitaciones Dia` | Entero | Habitaciones × días del mes | Aditiva · peso de ponderación |
| `Grado Ocup Plazas INE` | Porcentaje | Grado de ocupación por plazas publicado por el INE | **No aditiva** · ponderar por `Plazas Dia` |
| `Grado Ocup Plazas Finde INE` | Porcentaje | Grado de ocupación por plazas en fin de semana | **No aditiva** |
| `Grado Ocup Habitaciones INE` | Porcentaje | Grado de ocupación por habitaciones | **No aditiva** · ponderar por `Habitaciones Dia` |

Todas las columnas de `Fact_Oferta` están ocultas; se consumen mediante las medidas de la carpeta *02 Oferta*.

## Dim_Fecha

Calendario continuo · grano **día** · marcada como tabla de fechas.

| Columna | Tipo | Ejemplo | Notas |
|---|---|---|---|
| `Fecha` | Fecha | 15/08/2025 | Clave · tabla de fechas |
| `Año` | Entero | 2025 | Resumir por: ninguno |
| `Mes Num` | Entero | 8 | Oculta · criterio de orden |
| `Mes` | Texto | Agosto | Ordenar por `Mes Num` |
| `Mes Corto` | Texto | Ago | Ordenar por `Mes Num` |
| `Trimestre` | Texto | T3 | |
| `AñoMes Num` | Entero | 202508 | Oculta · criterio de orden |
| `Mes Año` | Texto | Ago 2025 | Ordenar por `AñoMes Num` |
| `Inicio Mes` | Fecha | 01/08/2025 | Iteración por meses en DAX |
| `Días Mes` | Entero | 31 | |
| `Temporada` | Texto | Alta | Alta (jul–ago), Media (jun, sep), Baja (resto) · ordenar por `Temporada Orden` |
| `Temporada Orden` | Entero | 1 | Oculta |
| `Con Datos` | Booleano | Verdadero | Columna calculada DAX · oculta |

## Dim_PuntoTuristico

Destinos turísticos · grano **destino**.

| Columna | Tipo | Ejemplo | Notas |
|---|---|---|---|
| `PuntoKey` | Entero | 1 | Clave suplente · oculta |
| `Punto Turístico` | Texto | Gijón | Nombre de negocio · categoría *Ciudad* · ordenar por `Orden` |
| `Nombre INE` | Texto | Gijón | Nombre literal del INE · oculta (clave natural) |
| `Comunidad Autónoma` | Texto | Principado de Asturias | Categoría *Estado o provincia* |
| `Provincia` | Texto | Asturias | |
| `Es Foco` | Texto | Sí | Destino principal del análisis |
| `Latitud` / `Longitud` | Decimal | 43.5322 / -5.6611 | Categorías de datos geográficas · resumir por: ninguno |
| `Orden` | Entero | 1 | Oculta |

## Dim_Residencia

Mercado emisor · grano **residencia**.

| Columna | Tipo | Valores |
|---|---|---|
| `ResidenciaKey` | Entero | 1, 2 (oculta) |
| `Residencia` | Texto | Residentes en España · Residentes en el extranjero |
| `Mercado` | Texto | Nacional · Internacional |
| `Orden` | Entero | 1, 2 (oculta) |

## Definiciones (INE · Encuesta de Ocupación Hotelera)

- **Viajero:** persona que realiza una o más pernoctaciones seguidas en el mismo alojamiento.
- **Pernoctación:** cada noche que un viajero se aloja en el establecimiento.
- **Estancia media:** pernoctaciones / viajeros.
- **Grado de ocupación por plazas:** pernoctaciones en relación con las plazas disponibles (incluidas camas supletorias) por los días del periodo, en porcentaje.
- **Punto turístico:** municipio con una concentración significativa de oferta hotelera para el que el INE publica datos específicos.

Metodología completa: [INE · Encuesta de Ocupación Hotelera](https://www.ine.es/dynt3/metadatos/es/RespuestaDatos.htm?oe=30235).
