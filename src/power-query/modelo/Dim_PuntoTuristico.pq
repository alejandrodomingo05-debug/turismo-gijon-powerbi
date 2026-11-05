// =====================================================================
//  Dim_PuntoTuristico  ·  Dimensión de destino (grano: punto turístico)
//  · Los miembros salen de los datos (lo que publica el INE).
//  · Los atributos (CCAA, provincia, coordenadas, orden, foco) vienen de
//    un CSV de referencia versionado en el propio repositorio y servido
//    por raw.githubusercontent.com (origen web público: no requiere
//    puerta de enlace para actualizar en el servicio).
//  · Clave suplente entera (PuntoKey): relaciones más ligeras que texto.
// =====================================================================
let
    // 1) Miembros presentes en los datos
    Puntos = Table.Distinct(Table.SelectColumns(stg_INE_Demanda, {"PuntoTuristico"})),

    // 2) Atributos de referencia (data/reference/ref_puntos_turisticos.csv)
    RefBinario = Web.Contents(pGitHubRawBase, [RelativePath = pRutaReferencia]),
    RefCsv = Csv.Document(RefBinario, [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]),
    Ref = Table.PromoteHeaders(RefCsv, [PromoteAllScalars = true]),
    RefTipada = Table.TransformColumnTypes(
        Ref,
        {
            {"Patron", type text},
            {"NombreCorto", type text},
            {"ComunidadAutonoma", type text},
            {"Provincia", type text},
            {"EsFoco", type text},
            {"Latitud", type number},
            {"Longitud", type number},
            {"Orden", Int64.Type}
        },
        "en-US"
    ),

    // 3) Emparejar cada punto INE con su fila de referencia por patrón
    ConRef = Table.AddColumn(
        Puntos,
        "Ref",
        (fila) =>
            Table.First(
                Table.SelectRows(
                    RefTipada,
                    each Text.Contains(fila[PuntoTuristico], [Patron], Comparer.OrdinalIgnoreCase)
                ),
                null
            )
    ),
    Expandido = Table.ExpandRecordColumn(
        ConRef,
        "Ref",
        {"NombreCorto", "ComunidadAutonoma", "Provincia", "EsFoco", "Latitud", "Longitud", "Orden"},
        {"NombreCorto", "Comunidad Autónoma", "Provincia", "Es Foco", "Latitud", "Longitud", "Orden"}
    ),

    // 4) Nombre visible: el de referencia o, si no existe, el del INE
    ConNombre = Table.AddColumn(
        Expandido,
        "Punto Turístico",
        each if [NombreCorto] = null then [PuntoTuristico] else [NombreCorto],
        type text
    ),
    ConOrden = Table.TransformColumns(ConNombre, {{"Orden", each if _ = null then 99 else _, Int64.Type}}),
    ConFoco = Table.TransformColumns(ConOrden, {{"Es Foco", each if _ = null then "No" else _, type text}}),

    // 5) Clave suplente estable dentro de cada actualización
    Ordenado = Table.Sort(ConFoco, {{"Orden", Order.Ascending}, {"Punto Turístico", Order.Ascending}}),
    ConClave = Table.AddIndexColumn(Ordenado, "PuntoKey", 1, 1, Int64.Type),
    Renombrado = Table.RenameColumns(ConClave, {{"PuntoTuristico", "Nombre INE"}}),
    Final = Table.SelectColumns(
        Renombrado,
        {"PuntoKey", "Punto Turístico", "Nombre INE", "Comunidad Autónoma", "Provincia", "Es Foco", "Latitud", "Longitud", "Orden"}
    )
in
    Final
