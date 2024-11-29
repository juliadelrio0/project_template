#!/bin/bash

# Configuración inicial
echo "Configurando el entorno..."

# Verificar si Python está instalado
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

# Instalar las dependencias
echo "Instalando dependencias..."
pip install --upgrade pip
pip install requests

# Desactivar el entorno virtual
deactivate

echo "Configuración completada con éxito."
