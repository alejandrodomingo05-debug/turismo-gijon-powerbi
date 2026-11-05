#!/usr/bin/env python3
"""
Descarga y valida las tablas de la Encuesta de Ocupación Hotelera (INE)
usadas por el dashboard, y guarda un extracto filtrado para trabajar
sin conexión o para depurar el ETL de Power Query.

Uso:
    python scripts/descargar_datos_ine.py
    python scripts/descargar_datos_ine.py --tablas 2078 2076 --patrones "Gijón;Oviedo"
    python scripts/descargar_datos_ine.py --desde-archivo data/raw/ine_2078.csv

Salida:
    data/raw/ine_<tabla>.csv              CSV original del INE (no se versiona)
    data/processed/ine_<tabla>_filtrado.csv  Sólo destinos de interés y meses

Sólo usa la biblioteca estándar de Python (3.9+).
"""
from __future__ import annotations

import argparse
import csv
import io
import re
import sys
import urllib.request
from pathlib import Path

URL_INE = "https://www.ine.es/jaxiT3/files/t/csv_bdsc/{tabla}.csv"
PATRONES_POR_DEFECTO = "Gijón;Oviedo;Santander;Bilbao;Coruña;Sebastián"
PERIODO_MENSUAL = re.compile(r"^\d{4}M\d{2}$")
RAIZ = Path(__file__).resolve().parents[1]


def descargar(tabla: str) -> bytes:
    peticion = urllib.request.Request(
        URL_INE.format(tabla=tabla),
        headers={"User-Agent": "turismo-gijon-powerbi/1.0 (open-data portfolio)"},
    )
    with urllib.request.urlopen(peticion, timeout=300) as respuesta:
        return respuesta.read()


def decodificar(contenido: bytes) -> str:
    for codificacion in ("utf-8-sig", "cp1252"):
        try:
            return contenido.decode(codificacion)
        except UnicodeDecodeError:
            continue
    raise ValueError("No se pudo decodificar el CSV (ni UTF-8 ni Windows-1252)")


def columna_por_patron(cabeceras: list[str], patron: str) -> int:
    for i, nombre in enumerate(cabeceras):
        if patron.lower() in nombre.lower():
            return i
    raise KeyError(f"No hay ninguna columna que contenga '{patron}': {cabeceras}")


def filtrar(texto: str, patrones: list[str]) -> tuple[list[str], list[list[str]]]:
    lector = csv.reader(io.StringIO(texto), delimiter=";")
    cabeceras = next(lector)
    i_punto = columna_por_patron(cabeceras, "punto")
    i_periodo = columna_por_patron(cabeceras, "periodo")
    filas = [
        fila
        for fila in lector
        if len(fila) == len(cabeceras)
        and PERIODO_MENSUAL.match(fila[i_periodo].strip())
        and any(p.lower() in fila[i_punto].lower() for p in patrones)
    ]
    return cabeceras, filas


def resumen(tabla: str, cabeceras: list[str], filas: list[list[str]], patrones: list[str]) -> None:
    i_punto = columna_por_patron(cabeceras, "punto")
    i_periodo = columna_por_patron(cabeceras, "periodo")
    puntos = sorted({f[i_punto].strip() for f in filas})
    periodos = sorted({f[i_periodo].strip() for f in filas})
    print(f"\nTabla {tabla}")
    print(f"  Columnas : {cabeceras}")
    print(f"  Filas    : {len(filas):,}".replace(",", "."))
    print(f"  Destinos : {puntos}")
    if periodos:
        print(f"  Periodo  : {periodos[0]} → {periodos[-1]}")
    sin_match = [p for p in patrones if not any(p.lower() in x.lower() for x in puntos)]
    if sin_match:
        print(f"  AVISO    : sin coincidencias para {sin_match}. Revisa el nombre exacto en INEbase.")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--tablas", nargs="+", default=["2078", "2076"], help="IDs de tabla INEbase")
    parser.add_argument("--patrones", default=PATRONES_POR_DEFECTO, help="Destinos separados por ';'")
    parser.add_argument("--desde-archivo", type=Path, help="Procesar un CSV ya descargado (una tabla)")
    args = parser.parse_args()

    patrones = [p.strip() for p in args.patrones.split(";") if p.strip()]
    dir_raw = RAIZ / "data" / "raw"
    dir_proc = RAIZ / "data" / "processed"
    dir_raw.mkdir(parents=True, exist_ok=True)
    dir_proc.mkdir(parents=True, exist_ok=True)

    origenes: list[tuple[str, bytes]] = []
    if args.desde_archivo:
        tabla = re.sub(r"\D", "", args.desde_archivo.stem) or "local"
        origenes.append((tabla, args.desde_archivo.read_bytes()))
    else:
        for tabla in args.tablas:
            print(f"Descargando tabla {tabla} del INE…")
            contenido = descargar(tabla)
            (dir_raw / f"ine_{tabla}.csv").write_bytes(contenido)
            origenes.append((tabla, contenido))

    for tabla, contenido in origenes:
        cabeceras, filas = filtrar(decodificar(contenido), patrones)
        destino = dir_proc / f"ine_{tabla}_filtrado.csv"
        with destino.open("w", newline="", encoding="utf-8") as f:
            escritor = csv.writer(f, delimiter=";")
            escritor.writerow(cabeceras)
            escritor.writerows(filas)
        resumen(tabla, cabeceras, filas, patrones)
        print(f"  Guardado : {destino.relative_to(RAIZ)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
