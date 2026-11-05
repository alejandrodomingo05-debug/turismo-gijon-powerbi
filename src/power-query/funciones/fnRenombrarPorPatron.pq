// =====================================================================
//  fnRenombrarPorPatron
//  Renombra columnas buscando un patrón (sin distinguir mayúsculas)
//  en lugar del nombre exacto. Hace el ETL resiliente a cambios menores
//  de redacción en las cabeceras del INE y falla con un error claro
//  si una columna esperada desaparece.
//
//  Uso: fnRenombrarPorPatron(tabla, {{"punto", "PuntoTuristico"}, {"periodo", "Periodo"}})
// =====================================================================
(tabla as table, mapeo as list) as table =>
let
    Columnas = Table.ColumnNames(tabla),
    Pares = List.Transform(
        mapeo,
        (par as list) =>
            let
                Coincidencias = List.Select(
                    Columnas,
                    each Text.Contains(_, par{0}, Comparer.OrdinalIgnoreCase)
                ),
                Encontrada =
                    if List.IsEmpty(Coincidencias) then
                        error Error.Record(
                            "EsquemaINE",
                            "No existe ninguna columna que contenga '" & par{0} & "'",
                            Columnas
                        )
                    else
                        Coincidencias{0}
            in
                {Encontrada, par{1}}
    ),
    Resultado = Table.RenameColumns(tabla, Pares)
in
    Resultado
