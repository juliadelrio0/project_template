#!/bin/bash

# Configuración inicial
echo "Configurando el entorno..."

# Verificar si Python3 está instalado
if ! command -v python3 &> /dev/null; then
    echo "Error: Python3 no está instalado. Por favor, instálalo antes de continuar."
    exit 1
fi

# Crear un entorno virtual (opcional pero recomendado)
if [ ! -d "env" ]; then
    echo "Creando un entorno virtual..."
    python3 -m venv env
    echo "Entorno virtual creado."
else
    echo "El entorno virtual ya existe."
fi

# Activar el entorno virtual
source env/bin/activate

# Instalar las dependencias de Python
echo "Instalando dependencias de Python..."
pip install --upgrade pip
pip install requests pandas

# Desactivar el entorno virtual
deactivate

# Verificar si R está instalado
if ! command -v R &> /dev/null; then
    echo "Error: R no está instalado. Por favor, instálalo antes de continuar."
    exit 1
fi

# Instalar las dependencias en R (igraph)
echo "Instalando dependencias en R..."
Rscript -e "if (!requireNamespace('igraph', quietly = TRUE)) install.packages('igraph')"
Rscript -e "if (!requireNamespace('optparse', quietly = TRUE)) install.packages('optparse')"

echo "Configuración completada con éxito."

