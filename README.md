# Proyecto de Análisis de Redes de Interacción Proteica y Enriquecimiento Funcional de Genes

## Descripción

Este proyecto se centra en el análisis de redes de interacción de proteínas (PPI) y el enriquecimiento funcional de genes. Utilizando herramientas de análisis de redes y de enriquecimiento funcional, este proyecto identifica genes relevantes en un conjunto de datos y examina su relación con funciones biológicas específicas.

Las principales tareas del proyecto incluyen:
- **Obtención de interacciones proteicas** usando la base de datos STRING.
- **Análisis de redes** para evaluar la relevancia de las proteínas utilizando métricas de centralidad.
- **Enriquecimiento funcional** de genes mediante GO y otras herramientas biológicas.
  
## Estructura del Proyecto

El proyecto está organizado en las siguientes carpetas:

- `code/`: Contiene los scripts para el análisis y procesamiento de datos.
- `results/`: Almacena los resultados generados, como archivos de salida y visualizaciones.
- `report/`: Carpeta destinada a los informes y documentación del proyecto.

## Requisitos

El proyecto utiliza las siguientes herramientas y dependencias:

### En R:
- `igraph`
- `clusterProfiler`
- `org.Hs.eg.db`
- `enrichplot`
- `optparse`


### En Python:
- `requests`
- `json`
- `sys`
- `pandas`
- `argparse`

## Instalación

Para comenzar con el proyecto, sigue estos pasos:

1. **Clona el repositorio**:
   git clone https://github.com/juliadelrio0/project_template
   cd project_template

2. **Ejecuta el archivo de SETUP**:
   bash ./setup.sh

## Ejecución

Para ejecutar el flujo de trabajo del proyecto, utiliza el script `launch.sh`:

```bash
bash launch.sh

   
