// =====================================================================
//  stg_INE_Demanda  ·  Staging (Habilitar carga: NO)
//  Origen : INE · EOH · Viajeros y pernoctaciones por puntos turísticos
//  Grano  : punto turístico × residencia × mes
//  Salida : PuntoTuristico | Residencia | Fecha | Viajeros | Pernoctaciones
// =====================================================================
let
    Origen = fnLeerTablaINE(pTablaDemanda),

    // 1) Nombres de columna estables (independientes de la redacción del INE)
    Renombrado = fnRenombrarPorPatron(
        Origen,
        {
            {"punto", "PuntoTuristico"},
            {"resid", "Residencia"},
            {"periodo", "Periodo"},
            {"total", "Valor"}
        }
    ),
    //    La columna restante es la de la medida ("Viajeros y pernoctaciones").
    //    Si el INE añade dimensiones nuevas, fallamos de forma explícita.
    Restantes = List.Difference(
        Table.ColumnNames(Renombrado),
        {"PuntoTuristico", "Residencia", "Periodo", "Valor"}
    ),
    ColMedida =
        if List.Count(Restantes) = 1 then
            Restantes{0}
        else
            error Error.Record(
                "EsquemaINE",
                "Se esperaba 1 columna de medida y hay " & Text.From(List.Count(Restantes)),
                Restantes
            ),
    ConMedida = Table.RenameColumns(Renombrado, {{ColMedida, "Medida"}}),

    // 2) Filtrar cuanto antes: sólo los puntos de interés y periodos mensuales
    //    (el CSV no admite plegado de consultas: filtrar pronto reduce memoria)
    Patrones = List.Transform(Text.Split(pPuntosTuristicos, ";"), Text.Trim),
    SoloPuntos = Table.SelectRows(
        ConMedida,
        each List.AnyTrue(
            List.Transform(
                Patrones,
                (p) => Text.Contains([PuntoTuristico], p, Comparer.OrdinalIgnoreCase)
            )
        )
    ),
    ConFecha = Table.AddColumn(
        SoloPuntos,
        "Fecha",
        each fnFechaDesdePeriodoINE([Periodo]),
        type nullable date
    ),
    SoloMensual = Table.SelectRows(ConFecha, each [Fecha] <> null),

    // 3) Valor: formato es-ES (1.234,5) y ".." / vacío = dato no disponible
    ValorLimpio = Table.TransformColumns(
        SoloMensual,
        {
            {
                "Valor",
                each if _ = null or List.Contains({"", ".", ".."}, Text.Trim(_)) then null else Text.Trim(_),
                type nullable text
            }
        }
    ),
    ValorNumerico = Table.TransformColumnTypes(ValorLimpio, {{"Valor", type number}}, "es-ES"),

    // 4) Normalizar etiquetas a un vocabulario controlado
    Normalizado = Table.TransformColumns(
        ValorNumerico,
        {
            {"PuntoTuristico", Text.Trim, type text},
            {
                "Medida",
                each
                    if Text.Contains(_, "viajer", Comparer.OrdinalIgnoreCase) then "Viajeros"
                    else if Text.Contains(_, "pernoct", Comparer.OrdinalIgnoreCase) then "Pernoctaciones"
                    else null,
                type nullable text
            },
            {
                "Residencia",
                each
                    if Text.Contains(_, "extranj", Comparer.OrdinalIgnoreCase) then "Extranjero"
                    else if Text.Contains(_, "espa", Comparer.OrdinalIgnoreCase) then "España"
                    else "Total",
                type text
            }
        }
    ),
    SoloMedidasConocidas = Table.SelectRows(Normalizado, each [Medida] <> null),

    // 5) Pivotar medidas a columnas: 1 fila = punto × residencia × mes
    SinPeriodo = Table.RemoveColumns(SoloMedidasConocidas, {"Periodo"}),
    Pivotado = Table.Pivot(
        SinPeriodo,
        {"Viajeros", "Pernoctaciones"},
        "Medida",
        "Valor",
        List.Sum
    ),

    // 6) Tipado final explícito
    Tipado = Table.TransformColumnTypes(
        Pivotado,
        {
            {"PuntoTuristico", type text},
            {"Residencia", type text},
            {"Fecha", type date},
            {"Viajeros", Int64.Type},
            {"Pernoctaciones", Int64.Type}
        }
    )
in
    Tipado
