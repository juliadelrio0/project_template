import requests
import json
import pandas as pd
import argparse
import shutil
import networkx as nx
import matplotlib.pyplot as plt
import os
import urllib.parse



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
            interactions_filtered = interactions_filtered[["preferredName_A", "preferredName_B", "score"]].drop_duplicates()
            return interactions_filtered
        else:
            print("No se encontraron interacciones.")
            return pd.DataFrame(columns=["preferredName_A", "preferredName_B", "score"])
    else:
        print(f"Error al conectar con STRINGdb: {response.status_code}")
        exit(1)
        
 
        
 

def fetch_and_show_graph(protein_names, species=9606, score_threshold=0.5):
    """
    Obtiene y muestra el grafo desde STRINGdb en formato de imagen.

    Args:
        protein_names (list): Lista de nombres de proteínas.
        species (int): ID de la especie (9606 para humanos).
        score_threshold (float): Umbral de confianza (valor entre 0 y 1).
    """
    # Construir la URL para la solicitud de imagen
    base_url = "https://string-db.org/api/image/network"
    identifiers = "%0d".join(protein_names)
    params = {
        "identifiers": identifiers,
        "species": species,
        "required_score": int(score_threshold * 1000),  # Convertir a escala STRING (0-1000)
    }
    
    response = requests.get(base_url, params=params, stream=True)

    if response.status_code == 200:
        # Guardar la imagen
        with open("string_graph.png", "wb") as img_file:
            shutil.copyfileobj(response.raw, img_file)
        print("Imagen descargada: string_graph.png")
        
    
    else:
        print(f"Error al obtener el grafo: {response.status_code}")





if __name__ == "__main__":
    # Configurar los argumentos de línea de comandos
    parser = argparse.ArgumentParser(description="Obtener interacciones de proteínas utilizando STRINGdb.")
    parser.add_argument("input_file", type=str, help="Archivo de entrada en formato JSON con los nombres de proteínas.")
    parser.add_argument("output_file", type=str, help="Archivo de salida en formato CSV para guardar las interacciones.")
    parser.add_argument("--score_threshold", type=float, default=0.5, help="Umbral de score mínimo (default: 0.5).")
    parser.add_argument("--verbose", action="store_true", help="Imprimir mensajes detallados de depuración.")

    # Parsear los argumentos
    args = parser.parse_args()

    # Leer el archivo JSON de entrada
    try:
        with open(args.input_file, "r", encoding="utf-8") as file:
            proteins = json.load(file)
        print("Archivo JSON leído correctamente.") if args.verbose else None
    except Exception as e:
        print(f"Error al leer el archivo JSON: {e}")
        exit(1)

    # Extraer los nombres de las proteínas
    protein_names = [protein["name"] for protein in proteins]
    print(f"Proteínas encontradas: {protein_names}") if args.verbose else None
    
    # Obtener las interacciones
    print(f"Obteniendo interacciones con score >= {args.score_threshold}...") if args.verbose else None
    interaction_network = fetch_interactions(protein_names, score_threshold=args.score_threshold)
    
    
    # Guardar la red de interacciones en un archivo CSV
    if not interaction_network.empty:
        interaction_network.to_csv(args.output_file, index=False)
        print(f"Red de interacciones guardada en: {args.output_file}")

        # Generar y guardar la imagen de la red
        fetch_and_show_graph(protein_names)

        # Dibujar el grafo de interacciones
    else:
        print("No se generó ningún archivo, ya que no se encontraron interacciones.")
