#!/bin/bash

# Activar el entorno virtual
echo "Activando el entorno virtual..."
source env/bin/activate

# Definir las rutas de los directorios
RESULTS_DIR="results"
PLOTS_DIR="report/figures"

# Crear los directorios si no existen
echo "Verificando y creando directorios si es necesario..."
mkdir -p "$PLOTS_DIR"
mkdir -p "$RESULTS_DIR"

# Establecer el código HPO por defecto (HP:0008316) y el umbral opcional
HPO_CODE="${1:-HP:0008316}"  # Si no se proporciona, usar HP:0008316 por defecto
THRESHOLD="$2"  # Si se proporciona, se usará el umbral, si no, se usa el valor por defecto en el script de fetch_interactions.py

# Ejecutar el script de Python hpo_genes_fetcher.py
echo "Ejecutando hpo_genes_fetcher.py con el código HPO: $HPO_CODE..."
python3 hpo_genes_fetcher.py "$HPO_CODE" "$RESULTS_DIR/genes_${HPO_CODE}.json"

# Ejecutar el script de Python fetch_interactions.py
echo "Ejecutando fetch_interactions.py con el archivo de genes generado..."
python3 fetch_interactions.py "$RESULTS_DIR/genes_${HPO_CODE}.json" "$RESULTS_DIR/interaction_network.csv" "$THRESHOLD"

# Ejecutar el script de R plot_network.R
echo "Ejecutando plot_network.R para generar las gráficas..."
Rscript plot_network.R "$RESULTS_DIR/interaction_network.csv" "$PLOTS_DIR" "$RESULTS_DIR"

# Desactivar el entorno virtual después de la ejecución
echo "Desactivando el entorno virtual..."
deactivate

echo "Programa ejecutado con éxito."

