// =====================================================================
//  fnLeerTablaINE
//  Descarga una tabla de INEbase en formato CSV (separador ';') y la
//  devuelve con las cabeceras promovidas.
//
//  Buenas prácticas aplicadas
//  · Web.Contents con URL base ESTÁTICA (parámetro) + RelativePath:
//    el servicio de Power BI puede validar el origen y programar la
//    actualización sin errores de "origen de datos dinámico".
//  · Encoding 65001 (UTF-8). Si las tildes salen corruptas, usar 1252.
//  · Timeout explícito: el CSV completo de la EOH pesa varios MB.
// =====================================================================
(idTabla as text) as table =>
let
    Binario = Web.Contents(
        pINE_BaseUrl,
        [
            RelativePath = "jaxiT3/files/t/csv_bdsc/" & idTabla & ".csv",
            Timeout = #duration(0, 0, 5, 0)
        ]
    ),
    Csv = Csv.Document(
        Binario,
        [Delimiter = ";", Encoding = 65001, QuoteStyle = QuoteStyle.Csv]
    ),
    ConCabeceras = Table.PromoteHeaders(Csv, [PromoteAllScalars = true])
in
    ConCabeceras
