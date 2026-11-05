// =====================================================================
//  fnFechaDesdePeriodoINE
//  Convierte el código de periodo mensual del INE ("2024M03") en la
//  fecha del primer día del mes (01/03/2024). Devuelve null para
//  periodos no mensuales (anuales, trimestrales...), lo que permite
//  usarla también como filtro.
// =====================================================================
(periodo as nullable text) as nullable date =>
    if periodo <> null
        and Text.Length(Text.Trim(periodo)) = 7
        and Text.At(Text.Trim(periodo), 4) = "M"
    then
        #date(
            Number.From(Text.Start(Text.Trim(periodo), 4)),
            Number.From(Text.End(Text.Trim(periodo), 2)),
            1
        )
    else
        null
