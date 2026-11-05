// =====================================================================
//  stg_INE_Oferta  ·  Staging (Habilitar carga: NO)
//  Origen : INE · EOH · Establecimientos, plazas estimadas, grados de
//           ocupación y personal empleado por puntos turísticos
//  Grano  : punto turístico × mes
//  Salida : PuntoTuristico | Fecha | Establecimientos | Habitaciones |
//           Plazas | PersonalEmpleado | GradoOcup* (en tanto por uno)
// =====================================================================
let
    Origen = fnLeerTablaINE(pTablaOferta),

    // 1) Nombres de columna estables
    Renombrado = fnRenombrarPorPatron(
        Origen,
        {
            {"punto", "PuntoTuristico"},
            {"periodo", "Periodo"},
            {"total", "Valor"}
        }
    ),
    Restantes = List.Difference(
        Table.ColumnNames(Renombrado),
        {"PuntoTuristico", "Periodo", "Valor"}
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

    // 2) Filtrar cuanto antes
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

    // 3) Valor numérico (formato es-ES; ".." = no disponible)
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

    // 4) Vocabulario controlado de medidas (el orden de las reglas importa)
    ConMedidaStd = Table.AddColumn(
        ValorNumerico,
        "MedidaStd",
        each
            let
                m = Text.Lower([Medida])
            in
                if Text.Contains(m, "fin de semana") then "GradoOcupPlazasFinSemana"
                else if Text.Contains(m, "ponderad") then "GradoOcupPlazasPonderado"
                else if Text.Contains(m, "ocupaci") and Text.Contains(m, "habitaci") then "GradoOcupHabitaciones"
                else if Text.Contains(m, "ocupaci") and Text.Contains(m, "plaza") then "GradoOcupPlazas"
                else if Text.Contains(m, "establecimiento") then "Establecimientos"
                else if Text.Contains(m, "habitaci") then "Habitaciones"
                else if Text.Contains(m, "plaza") then "Plazas"
                else if Text.Contains(m, "personal") then "PersonalEmpleado"
                else null,
        type nullable text
    ),
    SoloMedidasConocidas = Table.SelectRows(ConMedidaStd, each [MedidaStd] <> null),

    // 5) Pivotar: 1 fila = punto × mes
    Columnas = Table.SelectColumns(SoloMedidasConocidas, {"PuntoTuristico", "Fecha", "MedidaStd", "Valor"}),
    Pivotado = Table.Pivot(
        Columnas,
        {
            "Establecimientos", "Habitaciones", "Plazas", "PersonalEmpleado",
            "GradoOcupPlazas", "GradoOcupPlazasFinSemana", "GradoOcupPlazasPonderado", "GradoOcupHabitaciones"
        },
        "MedidaStd",
        "Valor",
        List.Sum
    ),

    // 6) Ratios en tanto por uno (26,5 -> 0,265): se formatean como % en el modelo
    RatiosDecimales = Table.TransformColumns(
        Pivotado,
        {
            {"GradoOcupPlazas", each if _ = null then null else _ / 100, Percentage.Type},
            {"GradoOcupPlazasFinSemana", each if _ = null then null else _ / 100, Percentage.Type},
            {"GradoOcupPlazasPonderado", each if _ = null then null else _ / 100, Percentage.Type},
            {"GradoOcupHabitaciones", each if _ = null then null else _ / 100, Percentage.Type}
        }
    ),

    // 7) Tipado final explícito
    Tipado = Table.TransformColumnTypes(
        RatiosDecimales,
        {
            {"PuntoTuristico", type text},
            {"Fecha", type date},
            {"Establecimientos", Int64.Type},
            {"Habitaciones", Int64.Type},
            {"Plazas", Int64.Type},
            {"PersonalEmpleado", Int64.Type}
        }
    )
in
    Tipado
