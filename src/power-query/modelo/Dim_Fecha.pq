// =====================================================================
//  Dim_Fecha  ·  Dimensión calendario (grano: día)
//  · Contigua, desde el 1 de enero del año de pFechaInicio hasta el
//    31 de diciembre del año en curso (requisito de las funciones de
//    inteligencia de tiempo).
//  · Marcar como tabla de fechas en el modelo (columna Fecha).
//  · Los hechos son mensuales (día 1 de cada mes): se relacionan por Fecha.
// =====================================================================
let
    FechaInicio = Date.StartOfYear(pFechaInicio),
    FechaFin = Date.EndOfYear(Date.From(DateTime.LocalNow())),
    NumDias = Duration.Days(FechaFin - FechaInicio) + 1,
    ListaFechas = List.Dates(FechaInicio, NumDias, #duration(1, 0, 0, 0)),
    Tabla = Table.FromList(ListaFechas, Splitter.SplitByNothing(), {"Fecha"}),
    Tipada = Table.TransformColumnTypes(Tabla, {{"Fecha", type date}}),

    // Atributos de calendario (nombres de negocio, en español)
    Anio = Table.AddColumn(Tipada, "Año", each Date.Year([Fecha]), Int64.Type),
    MesNum = Table.AddColumn(Anio, "Mes Num", each Date.Month([Fecha]), Int64.Type),
    Mes = Table.AddColumn(MesNum, "Mes", each Text.Proper(Date.MonthName([Fecha], "es-ES")), type text),
    MesCorto = Table.AddColumn(Mes, "Mes Corto", each Text.Start([Mes], 3), type text),
    Trimestre = Table.AddColumn(MesCorto, "Trimestre", each "T" & Text.From(Date.QuarterOfYear([Fecha])), type text),
    AnioMesNum = Table.AddColumn(Trimestre, "AñoMes Num", each Date.Year([Fecha]) * 100 + Date.Month([Fecha]), Int64.Type),
    MesAnio = Table.AddColumn(AnioMesNum, "Mes Año", each [Mes Corto] & " " & Text.From([Año]), type text),
    InicioMes = Table.AddColumn(MesAnio, "Inicio Mes", each Date.StartOfMonth([Fecha]), type date),
    DiasMes = Table.AddColumn(InicioMes, "Días Mes", each Date.DaysInMonth([Fecha]), Int64.Type),

    // Temporada turística de Gijón (sol y playa del Cantábrico)
    Temporada = Table.AddColumn(
        DiasMes,
        "Temporada",
        each
            if List.Contains({7, 8}, [Mes Num]) then "Alta"
            else if List.Contains({6, 9}, [Mes Num]) then "Media"
            else "Baja",
        type text
    ),
    TemporadaOrden = Table.AddColumn(
        Temporada,
        "Temporada Orden",
        each if [Temporada] = "Alta" then 1 else if [Temporada] = "Media" then 2 else 3,
        Int64.Type
    )
in
    TemporadaOrden
