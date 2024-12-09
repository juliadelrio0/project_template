import requests
import pandas as pd
import argparse
import os
import shutil

def fetch_interactions(protein_names, species=9606, score_threshold=0.5):
    """
    Obtiene las interacciones entre proteínas a partir de sus nombres.

    Args:
        protein_names (list): Lista de nombres de proteínas.
        species (int): ID de especie (9606 para humanos).
        score_threshold (float): Umbral mínimo para el score de interacción (valor entre 0 y 1).

    Returns:
        pd.DataFrame: DataFrame con las interacciones filtradas por score.
    """
    url = "https://string-db.org/api/json/network"
    params = {
        "identifiers": "%0d".join(protein_names),
        "species": species,
    }
    response = requests.post(url, data=params)

    if response.status_code == 200:
        data = response.json()
        interactions = pd.DataFrame(data)
        if not interactions.empty:
            # Filtrar por score (se espera que el score esté entre 0 y 1)
            interactions_filtered = interactions[interactions["score"] >= score_threshold]
            return interactions_filtered[["preferredName_A", "preferredName_B", "score"]].drop_duplicates()
        else:
            print("No se encontraron interacciones.")
            return pd.DataFrame(columns=["preferredName_A", "preferredName_B", "score"])
    else:
        print(f"Error al conectar con STRINGdb: {response.status_code}")
        exit(1)

def fetch_and_save_graph(protein_names, output_dir, species=9606, score_threshold=0.9):
    """
    Descarga y guarda la imagen del grafo de interacciones desde STRINGdb.

    Args:
        protein_names (list): Lista de nombres de proteínas.
        output_dir (str): Directorio donde se guardará la imagen.
        species (int): ID de la especie (9606 para humanos).
        score_threshold (float): Umbral mínimo de confianza (valor entre 0 y 1).

    Returns:
        None
    """
    base_url = "https://string-db.org/api/image/network"
    params = {
        "identifiers": "%0d".join(protein_names),
        "species": species,
        "required_score": int(score_threshold * 1000),  # Convertir a escala STRING (0-1000)
    }

    response = requests.get(base_url, params=params, stream=True)

    if response.status_code == 200:
        # Asegurarse de que el directorio de salida exista
        os.makedirs(output_dir, exist_ok=True)
        output_file = os.path.join(output_dir, "string_graph.png")
        # Guardar la imagen en el directorio especificado
        with open(output_file, "wb") as img_file:
            shutil.copyfileobj(response.raw, img_file)
        print(f"Imagen del grafo guardada en: {output_file}")
    else:
        print(f"Error al obtener la imagen del grafo: {response.status_code}")

if __name__ == "__main__":
    # Configurar los argumentos de línea de comandos
    parser = argparse.ArgumentParser(description="Obtener interacciones de proteínas utilizando STRINGdb.")
    parser.add_argument("--i", type=str, required=True, help="Archivo de entrada en formato TXT con la lista de genes.")
    parser.add_argument("--dir_out", type=str, required=True, help="Directorio de salida para guardar las interacciones en formato CSV.")
    parser.add_argument("--dir_img", type=str, required=True, help="Directorio donde guardar la imagen del grafo.")
    parser.add_argument("--score_threshold", type=float, default=0.5, help="Umbral de score mínimo (default: 0.5).")
    parser.add_argument("--verbose", action="store_true", help="Imprimir mensajes detallados de depuración.")

    # Parsear los argumentos
    args = parser.parse_args()

    # Leer el archivo de entrada (gene_list.txt)
    try:
        with open(args.i, "r", encoding="utf-8") as file:
            protein_names = [line.strip() for line in file.readlines()]
        print("Archivo de genes leído correctamente.") if args.verbose else None
    except Exception as e:
        print(f"Error al leer el archivo de genes: {e}")
        exit(1)

    # Obtener las interacciones
    print(f"Obteniendo interacciones con score >= {args.score_threshold}...") if args.verbose else None
    interaction_network = fetch_interactions(protein_names, score_threshold=args.score_threshold)

    # Asegurarse de que el directorio de salida exista
    os.makedirs(args.dir_out, exist_ok=True)

    # Crear la ruta completa del archivo de salida
    output_file = os.path.join(args.dir_out, "interacciones_proteinas.csv")

    # Guardar la red de interacciones en un archivo CSV
    if not interaction_network.empty:
        interaction_network.to_csv(output_file, index=False)
        print(f"Red de interacciones guardada en: {output_file}")

        # Generar y guardar la imagen de la red
        fetch_and_save_graph(protein_names, args.dir_img, score_threshold=args.score_threshold)
    else:
        print("No se generó ningún archivo, ya que no se encontraron interacciones.")






