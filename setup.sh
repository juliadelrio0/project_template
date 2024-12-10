#!/bin/bash

# Definir directorio de instalación local
INSTALL_DIR="$HOME/software"
echo "Creando directorio de instalación en $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR" || { echo "Error: No se pudo crear el directorio $INSTALL_DIR"; exit 1; }
cd "$INSTALL_DIR" || { echo "Error: No se pudo cambiar al directorio $INSTALL_DIR"; exit 1; }

# --- Python ---
echo "Configurando entorno virtual de Python..."

# Verificar si Python3 está instalado
if ! command -v python3 &>/dev/null; then
    echo "Error: Python3 no está instalado. Por favor, instálalo primero."
    exit 1
fi

# Crear un entorno virtual de Python
python3 -m venv venv_python || { echo "Error: No se pudo crear el entorno virtual de Python"; exit 1; }

# Activar el entorno virtual de Python
source venv_python/bin/activate || { echo "Error: No se pudo activar el entorno virtual de Python"; exit 1; }

# Instalar las dependencias de Python
echo "Instalando dependencias de Python..."
pip install --upgrade pip
pip install pandas requests argparse || { echo "Error: No se pudieron instalar las dependencias de Python"; deactivate; exit 1; }

# Desactivar el entorno virtual de Python
deactivate

# --- R ---
echo "Configurando paquetes de R..."

# Verificar si Rscript está instalado
if ! command -v Rscript &>/dev/null; then
    echo "Error: Rscript no está instalado. Por favor, instala R primero."
    exit 1
fi

# Crear un entorno de R local para evitar conflictos
R_PROFILE_USER="$HOME/.Rprofile"
echo "Configurando perfil de R en $R_PROFILE_USER..."
echo "local({r <- getOption('repos'); r['CRAN'] <- 'https://cloud.r-project.org/'; options(repos=r)})" > "$R_PROFILE_USER"

# Instalación de paquetes de R
echo "Instalando paquetes de R..."
Rscript -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager', repos='https://cran.r-project.org')" || { echo "Error: No se pudo instalar 'BiocManager'"; exit 1; }
Rscript -e "if (!requireNamespace('igraph', quietly = TRUE)) install.packages('igraph', repos='https://cran.r-project.org')" || { echo "Error: No se pudo instalar 'igraph'"; exit 1; }
Rscript -e "if (!requireNamespace('optparse', quietly = TRUE)) install.packages('optparse', repos='https://cran.r-project.org')" || { echo "Error: No se pudo instalar 'optparse'"; exit 1; }
Rscript -e "if (!requireNamespace('clusterProfiler', quietly = TRUE)) BiocManager::install('clusterProfiler')" || { echo "Error: No se pudo instalar 'clusterProfiler'"; exit 1; }
Rscript -e "if (!requireNamespace('org.Hs.eg.db', quietly = TRUE)) BiocManager::install('org.Hs.eg.db')" || { echo "Error: No se pudo instalar 'org.Hs.eg.db'"; exit 1; }
Rscript -e "if (!requireNamespace('enrichplot', quietly = TRUE)) BiocManager::install('enrichplot')" || { echo "Error: No se pudo instalar 'enrichplot'"; exit 1; }

echo "Instalación completada con éxito."
