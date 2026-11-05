// =====================================================================
//  stg_RefPuntos  ·  Staging (Habilitar carga: NO)
//  Atributos de referencia de los destinos (CCAA, provincia, coordenadas,
//  orden, foco), versionados en data/reference/ref_puntos_turisticos.csv.
//
//  · Esta consulta es la ÚNICA que accede a GitHub. Dim_PuntoTuristico la
//    referencia en lugar de leer la web directamente: una consulta que
//    referencia otras consultas y además accede a un origen provoca el
//    error Formula.Firewall ("rebuild this data combination").
//  · Si el repositorio no está accesible (sin conexión, repo privado o aún
//    no publicado) se usa la copia incrustada: el informe siempre carga.
// =====================================================================
let
    // Table.Buffer fuerza la descarga DENTRO del try: sin él, M evalúa la
    // tabla de forma diferida y un error 404 escaparía al otherwise.
    Remota =
        try
            Table.Buffer(
                Table.PromoteHeaders(
                    Csv.Document(
                        Web.Contents(pGitHubRawBase, [RelativePath = pRutaReferencia]),
                        [Delimiter = ",", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
                    ),
                    [PromoteAllScalars = true]
                )
            )
        otherwise
            null,
    Incrustada = #table(
        {"Patron", "NombreCorto", "ComunidadAutonoma", "Provincia", "EsFoco", "Latitud", "Longitud", "Orden"},
        {
            {"Gijón", "Gijón", "Principado de Asturias", "Asturias", "Sí", "43.5322", "-5.6611", "1"},
            {"Oviedo", "Oviedo", "Principado de Asturias", "Asturias", "No", "43.3614", "-5.8494", "2"},
            {"Santander", "Santander", "Cantabria", "Cantabria", "No", "43.4623", "-3.8100", "3"},
            {"Bilbao", "Bilbao", "País Vasco", "Bizkaia", "No", "43.2630", "-2.9350", "4"},
            {"Sebastián", "Donostia-San Sebastián", "País Vasco", "Gipuzkoa", "No", "43.3183", "-1.9812", "5"},
            {"Coruña", "A Coruña", "Galicia", "A Coruña", "No", "43.3623", "-8.4115", "6"}
        }
    ),
    Origen =
        if Remota <> null and Table.HasColumns(Remota, {"Patron", "NombreCorto", "Orden"}) then
            Remota
        else
            Incrustada,
    Tipado = Table.TransformColumnTypes(
        Origen,
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
    )
in
    Tipado
