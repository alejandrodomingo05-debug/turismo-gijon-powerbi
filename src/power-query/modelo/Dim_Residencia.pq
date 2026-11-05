// =====================================================================
//  Dim_Residencia  ·  Dimensión de mercado emisor (grano: residencia)
//  Tabla estática: el INE sólo distingue residentes en España / extranjero.
//  La fila "Total" del INE NO es un miembro: se elimina en Fact_Demanda.
// =====================================================================
let
    Origen = #table(
        type table [
            ResidenciaKey = Int64.Type,
            Residencia = text,
            Mercado = text,
            Orden = Int64.Type
        ],
        {
            {1, "Residentes en España", "Nacional", 1},
            {2, "Residentes en el extranjero", "Internacional", 2}
        }
    )
in
    Origen
