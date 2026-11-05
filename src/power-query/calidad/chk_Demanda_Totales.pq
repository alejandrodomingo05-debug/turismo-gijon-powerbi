// =====================================================================
//  chk_Demanda_Totales  ·  Control de calidad (Habilitar carga: NO)
//  Comprueba que la fila "Total" del INE = España + Extranjero para cada
//  punto y mes. Resultado esperado: tabla VACÍA. Cualquier fila indica
//  datos secretos/no disponibles o un cambio en el esquema del origen.
// =====================================================================
let
    Origen = stg_INE_Demanda,
    Totales = Table.SelectRows(Origen, each [Residencia] = "Total"),
    Desglose = Table.Group(
        Table.SelectRows(Origen, each [Residencia] <> "Total"),
        {"PuntoTuristico", "Fecha"},
        {
            {"ViajerosSuma", each List.Sum([Viajeros]), type nullable number},
            {"PernoctacionesSuma", each List.Sum([Pernoctaciones]), type nullable number}
        }
    ),
    Cruce = Table.NestedJoin(
        Totales, {"PuntoTuristico", "Fecha"},
        Desglose, {"PuntoTuristico", "Fecha"},
        "D", JoinKind.LeftOuter
    ),
    Expandido = Table.ExpandTableColumn(Cruce, "D", {"ViajerosSuma", "PernoctacionesSuma"}),
    ConDiferencias = Table.AddColumn(
        Expandido,
        "Diferencia",
        each Number.Abs(([Viajeros] ?? 0) - ([ViajerosSuma] ?? 0))
            + Number.Abs(([Pernoctaciones] ?? 0) - ([PernoctacionesSuma] ?? 0)),
        type number
    ),
    // Tolerancia de 1 unidad por redondeos de publicación
    Incidencias = Table.SelectRows(ConDiferencias, each [Diferencia] > 1)
in
    Incidencias
