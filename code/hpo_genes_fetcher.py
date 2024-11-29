import requests
import json
import sys

def fetch_genes(hpo_id):
    """
    Realiza la solicitud a la API para obtener los genes asociados a un término HPO.

    Args:
        hpo_id (str): ID del término HPO.

    Returns:
        list: Lista de genes asociados al término HPO.
    """
    url = f"https://ontology.jax.org/api/network/annotation/{hpo_id}"
    response = requests.get(url)
    
    if response.status_code == 200:
        data = response.json()
        return data.get("genes", [])
    else:
        print(f"Error en la solicitud: {response.status_code}")
        sys.exit(1)

def save_genes_to_file(genes, output_file):
    """
    Guarda la lista de genes en un archivo.

    Args:
        genes (list): Lista de genes a guardar.
        output_file (str): Ruta del archivo de salida.
    """
    try:
        with open(output_file, "w", encoding="utf-8") as file:
            json.dump(genes, file, indent=4)
        print(f"Archivo guardado exitosamente en: {output_file}")
    except Exception as e:
        print(f"Error al guardar el archivo: {e}")
        sys.exit(1)

if __name__ == "__main__":
    # Verificar si se proporcionaron los argumentos necesarios
    if len(sys.argv) != 3:
        print("Uso: python hpo_genes_fetcher.py <HPO_ID> <output_file>")
        sys.exit(1)
    
    # Leer argumentos desde la línea de comandos
    hpo_id = sys.argv[1]
    output_file = sys.argv[2]

    # Obtener los genes asociados al HPO
    genes = fetch_genes(hpo_id)

    # Guardar los genes en el archivo de salida
    save_genes_to_file(genes, output_file)
