# Imagen con R precargado
FROM rocker/r-ver:4.3.1

# Instalar Python y pip
RUN apt-get update && apt-get install -y python3 python3-venv python3-pip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Usamos la carpeta app para trabajar
WORKDIR /app

# Copiamos todo a la carpeta
COPY . /app

# Instalamos dependencias de Python
RUN python3 -m venv /env && \
    /env/bin/pip install --upgrade pip && \
    /env/bin/pip install requests pandas

# Instalamos dependencias de R
RUN Rscript -e "if (!requireNamespace('igraph', quietly = TRUE)) install.packages('igraph', repos='https://cran.r-project.org')" && \
    Rscript -e "if (!requireNamespace('optparse', quietly = TRUE)) install.packages('optparse', repos='https://cran.r-project.org')"


ENV PATH="/env/bin:$PATH"

CMD ["bash"]
