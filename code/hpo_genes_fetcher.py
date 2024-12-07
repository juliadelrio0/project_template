import requests
import sys
import os
import argparse

def fetch_genes(hpo_id):
    """
    Realiza la solicitud a la API para obtener los genes asociados a un término HPO.

    Args:
        hpo_id (str): ID del término HPO.

    Returns:
        list: Lista de nombres de genes asociados al término HPO.
    """
    url = f"https://ontology.jax.org/api/network/annotation/{hpo_id}"
    response = requests.get(url)
    
    if response.status_code == 200:
        data = response.json()
        # Extraer los nombres de los genes
        return [gene["name"] for gene in data.get("genes", [])]
    else:
        print(f"Error en la solicitud: {response.status_code}")
        sys.exit(1)

def save_genes_to_file(genes, output_dir):
    """
    Guarda la lista de genes en un archivo de texto.

    Args:
        genes (list): Lista de nombres de genes a guardar.
        output_dir (str): Directorio donde se guardará el archivo.
    """
    try:
        # Asegurarse de que el directorio existe
        os.makedirs(output_dir, exist_ok=True)

        # Crear la ruta completa del archivo
        output_file = os.path.join(output_dir, "genes_list.txt")
        
        # Guardar los nombres de los genes en el archivo
        with open(output_file, "w", encoding="utf-8") as file:
            for gene in genes:
                file.write(gene + "\n")  # Corregido: "\n" para salto de línea
        
        print(f"Archivo guardado exitosamente en: {output_file}")
    except Exception as e:
        print(f"Error al guardar el archivo: {e}")
        sys.exit(1)

if __name__ == "__main__":
    # Crear un parser de argumentos
    parser = argparse.ArgumentParser(description="Fetch gene names associated with an HPO term and save to a file.")
    parser.add_argument("--hpo", required=True, help="ID del término HPO.")
    parser.add_argument("--dir", required=True, help="Directorio de salida para guardar el archivo de genes.")
    
    # Parsear los argumentos
    args = parser.parse_args()

    # Obtener los nombres de los genes asociados al HPO
    genes = fetch_genes(args.hpo)

    # Guardar los nombres de los genes en el directorio de salida
    save_genes_to_file(genes, args.dir)

