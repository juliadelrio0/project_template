#!/bin/bash

# Cargar el entorno virtual de Python
source "$HOME/software/venv_python/bin/activate"

# Crear directorios de resultados si no existen
mkdir -p results/img/fa_ora results/enrich results/img/network results/img/clusters

# Ejecutar el flujo de trabajo
python ./code/hpo_genes_fetcher.py --hpo HP:0008316 --dir ./results/enrich
python ./code/fetch_interactions.py --i ./results/enrich/genes_list.txt --dir_out ./results --dir_img ./results/img/network --score_threshold 0.9
Rscript ./code/plot_network.R --i ./results/interacciones_proteinas.csv --dir_res ./results --dir_img ./results/img/network --dir_genes ./results/enrich
Rscript ./code/cluster_proteinas.R --red ./results/interacciones_proteinas.csv --dirimg ./results/img/clusters --dirgenclus ./results/enrich --dirres ./results
Rscript ./code/functional_analysis.R --dir_i ./results/enrich --dir_o ./results/img/fa_ora

echo "Ejecución completada. Resultados disponibles en la carpeta 'results'."
