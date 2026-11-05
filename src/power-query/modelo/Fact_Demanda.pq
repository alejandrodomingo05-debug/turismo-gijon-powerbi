// =====================================================================
//  Fact_Demanda  ·  Hechos de demanda hotelera
//  Grano  : mes × punto turístico × residencia
//  Medidas: Viajeros, Pernoctaciones (aditivas)
// =====================================================================
let
    Origen = stg_INE_Demanda,

    // Evitar el doble conteo: el INE publica también la fila "Total"
    // (= España + Extranjero). En un modelo en estrella el total lo
    // calcula el motor; nunca se almacena como un miembro más.
    SinTotal = Table.SelectRows(Origen, each [Residencia] <> "Total"),
    DesdeInicio = Table.SelectRows(SinTotal, each [Fecha] >= pFechaInicio),

    // Claves foráneas
    ConResidenciaKey = Table.AddColumn(
        DesdeInicio,
        "ResidenciaKey",
        each if [Residencia] = "España" then 1 else 2,
        Int64.Type
    ),
    CruceDim = Table.NestedJoin(
        ConResidenciaKey, {"PuntoTuristico"},
        Dim_PuntoTuristico, {"Nombre INE"},
        "Dim", JoinKind.Inner
    ),
    ConPuntoKey = Table.ExpandTableColumn(CruceDim, "Dim", {"PuntoKey"}),

    // Sólo claves + medidas (tabla estrecha = mejor compresión VertiPaq)
    Final = Table.SelectColumns(
        ConPuntoKey,
        {"Fecha", "PuntoKey", "ResidenciaKey", "Viajeros", "Pernoctaciones"}
    ),
    Tipado = Table.TransformColumnTypes(
        Final,
        {
            {"Fecha", type date},
            {"PuntoKey", Int64.Type},
            {"ResidenciaKey", Int64.Type},
            {"Viajeros", Int64.Type},
            {"Pernoctaciones", Int64.Type}
        }
    )
in
    Tipado
