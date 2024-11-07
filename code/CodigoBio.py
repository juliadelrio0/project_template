import requests
import pandas as pd
import stringdb

def buscar_genes(hpo_id):
    """
    Función que busca los genes asociados a un fenotipo dado por su ID HPO y guarda los resultados en un archivo de texto.

    :param hpo_id: ID del fenotipo de HPO (ej. "HP:0008316").
    :param archivo_guardado: Ruta completa donde se guardará el archivo de texto con los genes.
    """
    # URL de la API con el ID del fenotipo
    HPO_GENES = f"https://ontology.jax.org/api/network/annotation/{hpo_id}/download/gene"
    
    # Realizar la solicitud GET a la API
    response = requests.get(HPO_GENES)
    
    # Verificar si la solicitud fue exitosa
    if response.status_code == 200:
        # Guardar el contenido del archivo en un archivo de texto
        with open("C:/Users/jesus/OneDrive - Universidad de Málaga/Cuarto/BiologiaSistemas/Trabajo/HPO_0008316_genes.txt", "w") as f:
            f.write(response.text)  # Guardar el contenido en formato de texto
        
        print("Archivo de genes guardado")
    else:
        print(f"Error al acceder a la API: {response.status_code}")

#limpiamos los genes:

with open("C:/Users/jesus/OneDrive - Universidad de Málaga/Cuarto/BiologiaSistemas/Trabajo/HPO_0008316_genes.txt", 'r') as f:
    lines = f.readlines()[1:]  # Omite la primera línea si es un encabezado

# Extraer los nombres de los genes de cada línea
gene_names = [line.split()[1] for line in lines]

# Formatea los nombres para la consulta en STRING (separados por %0d)
formatted_genes = "%0d".join(gene_names)
    
    

# Paso 2: Acceder a string db
def obtener_red(genes):

    # Paso 2: Realiza la solicitud a STRINGdb
    base_url = "https://string-db.org/api/json/network"
    params = {
        "identifiers": formatted_genes,  # Lista de genes formateada
        "species": 9606,                 # Especie Homo sapiens (código NCBI: 9606)
        "required_score": 800,           # Umbral de confianza para la interacción
        "network_flavor": "confidence",  # Tipo de red (confidence para confianza)
        "caller_identity": "example_app" # Identificación de la solicitud
    }
    
    response = requests.get(base_url, params=params)
    
    if response.status_code == 200:
        # Paso 3: Procesa la respuesta en un DataFrame
        interactions = response.json()
        interactions_df = pd.DataFrame(interactions)
    
        # Paso 4: Guarda las interacciones en un archivo tabular (CSV)
        interactions_df.to_csv('C:/Users/jesus/OneDrive - Universidad de Málaga/Cuarto/BiologiaSistemas/Trabajo/interacciones_genes.csv', index=False)
        print("Archivo 'interacciones_genes.csv' creado exitosamente con las relaciones.")
        
        interactions_df.to_string('C:/Users/jesus/OneDrive - Universidad de Málaga/Cuarto/BiologiaSistemas/Trabajo/interacciones_genes.txt', index=False)
        print("Archivo 'interacciones_genes.txt' creado exitosamente con las relaciones.")
    
    else:
        print(f"Error en la solicitud a STRINGdb: {response.status_code}")
        

def obtener_enriquecimiento_pathways(genes, species=9606, output_file="pathway_enrichment.csv"):
    # Obtener los datos de enriquecimiento para los genes
    enrichment_df = stringdb.get_enrichment(genes)
    
    # Ordenar los resultados por el valor de 'fdr'
    enrichment_df = enrichment_df.sort_values('fdr')

    # Guardar todo el DataFrame en un archivo CSV
    enrichment_df.to_csv(output_file, index=False)  # Guardamos el DataFrame sin los índices
    print(f"Enriquecimiento de pathways guardado en {output_file}")
    
hpo_id = "HP:0008316"
buscar_genes(hpo_id) 
obtener_red(formatted_genes)

obtener_enriquecimiento_pathways(formatted_genes)

