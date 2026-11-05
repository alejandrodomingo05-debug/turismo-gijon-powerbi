// =====================================================================
//  Fact_Oferta  ·  Hechos de oferta y ocupación hotelera (snapshot mensual)
//  Grano  : mes × punto turístico
//  Medidas: Establecimientos, Habitaciones, Plazas, Personal (semiaditivas:
//           se suman entre puntos, se promedian entre meses) y grados de
//           ocupación del INE (no aditivos: se ponderan en DAX).
// =====================================================================
let
    Origen = stg_INE_Oferta,
    DesdeInicio = Table.SelectRows(Origen, each [Fecha] >= pFechaInicio),

    CruceDim = Table.NestedJoin(
        DesdeInicio, {"PuntoTuristico"},
        Dim_PuntoTuristico, {"Nombre INE"},
        "Dim", JoinKind.Inner
    ),
    ConPuntoKey = Table.ExpandTableColumn(CruceDim, "Dim", {"PuntoKey"}),

    // Capacidad del mes (stock × días): peso para agregar ratios correctamente
    ConPlazasDia = Table.AddColumn(
        ConPuntoKey,
        "Plazas Dia",
        each if [Plazas] = null then null else [Plazas] * Date.DaysInMonth([Fecha]),
        Int64.Type
    ),
    ConHabitacionesDia = Table.AddColumn(
        ConPlazasDia,
        "Habitaciones Dia",
        each if [Habitaciones] = null then null else [Habitaciones] * Date.DaysInMonth([Fecha]),
        Int64.Type
    ),

    Final = Table.SelectColumns(
        ConHabitacionesDia,
        {
            "Fecha", "PuntoKey",
            "Establecimientos", "Habitaciones", "Plazas", "PersonalEmpleado",
            "Plazas Dia", "Habitaciones Dia",
            "GradoOcupPlazas", "GradoOcupPlazasFinSemana", "GradoOcupHabitaciones"
        }
    ),
    Renombrado = Table.RenameColumns(
        Final,
        {
            {"PersonalEmpleado", "Personal Empleado"},
            {"GradoOcupPlazas", "Grado Ocup Plazas INE"},
            {"GradoOcupPlazasFinSemana", "Grado Ocup Plazas Finde INE"},
            {"GradoOcupHabitaciones", "Grado Ocup Habitaciones INE"}
        }
    ),
    Tipado = Table.TransformColumnTypes(
        Renombrado,
        {
            {"Fecha", type date},
            {"PuntoKey", Int64.Type},
            {"Establecimientos", Int64.Type},
            {"Habitaciones", Int64.Type},
            {"Plazas", Int64.Type},
            {"Personal Empleado", Int64.Type},
            {"Plazas Dia", Int64.Type},
            {"Habitaciones Dia", Int64.Type},
            {"Grado Ocup Plazas INE", Percentage.Type},
            {"Grado Ocup Plazas Finde INE", Percentage.Type},
            {"Grado Ocup Habitaciones INE", Percentage.Type}
        }
    )
in
    Tipado
