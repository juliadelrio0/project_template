# Imagen base con R y Python preinstalados
FROM rocker/r-ver:4.3.1

# Instalar Python y herramientas necesarias
RUN apt-get update && apt-get install -y \
    python3 \
    python3-venv \
    python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Crear un entorno virtual para Python
RUN python3 -m venv /env && \
    /env/bin/pip install --upgrade pip

# Agregar el entorno virtual al PATH
ENV PATH="/env/bin:$PATH"

# Instalar las bibliotecas necesarias en Python
RUN pip install requests pandas

# Instalar paquetes necesarios de R
RUN Rscript -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager', repos='https://cran.r-project.org')" && \
    Rscript -e "if (!requireNamespace('igraph', quietly = TRUE)) install.packages('igraph', repos='https://cran.r-project.org')" && \
    Rscript -e "if (!requireNamespace('optparse', quietly = TRUE)) install.packages('optparse', repos='https://cran.r-project.org')" && \
    Rscript -e "if (!requireNamespace('clusterProfiler', quietly = TRUE)) BiocManager::install('clusterProfiler')" && \
    Rscript -e "if (!requireNamespace('org.Hs.eg.db', quietly = TRUE)) BiocManager::install('org.Hs.eg.db')" && \
    Rscript -e "if (!requireNamespace('enrichplot', quietly = TRUE)) BiocManager::install('enrichplot')"

# Crear un directorio de trabajo
WORKDIR /app

# Copiar todos los archivos al contenedor
COPY . /app

# Crear directorios necesarios
RUN mkdir -p /app/results/img/fa_ora /app/results/enrich /app/results/img/network /app/results/img/clusters

# Comando para ejecutar todo el flujo de trabajo
CMD bash -c "\
    python ./code/hpo_genes_fetcher.py --hpo HP:0008316 --dir ./results/enrich && \
    python ./code/fetch_interactions.py --i ./results/enrich/genes_list.txt --dir_out ./results --dir_img ./results/img/network --score_threshold 0.9 && \
    Rscript ./code/plot_network.R --i ./results/interacciones_proteinas.csv --dir_res ./results --dir_img ./results/img/network --dir_genes ./results/enrich && \
    Rscript ./code/cluster_proteinas.R --red ./results/interacciones_proteinas.csv --dirimg ./results/img/clusters --dirgenclus ./results/enrich --dirres ./results && \
    Rscript ./code/functional_analysis.R --dir_i ./results/enrich --dir_o ./results/img/fa_ora"
