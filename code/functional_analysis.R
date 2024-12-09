# Cargar las librerías necesarias
library(clusterProfiler)
library(org.Hs.eg.db)
library(enrichplot)
library(optparse)
library(ggplot2)

# Definir los argumentos de línea de comandos
option_list <- list(
  make_option("--dir_i", type = "character", default = NULL, 
              help = "Directorio que contiene los archivos de genes", metavar = "DIRECTORIO_ENTRADA"),
  make_option("--dir_o", type = "character", default = NULL, 
              help = "Directorio para guardar los gráficos", metavar = "DIRECTORIO_SALIDA")
)

# Parsear los argumentos
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

# Verificar si se proporcionaron los directorios de entrada y salida
if (is.null(opt$dir_i) | is.null(opt$dir_o)) {
  print("Debe proporcionar ambos directorios: --dir_i y --dir_o")
  quit(status = 1)
}

# Verificar si el directorio de salida existe, si no, crearlo
if (!dir.exists(opt$dir_o)) {
  dir.create(opt$dir_o, recursive = TRUE)
  print(paste("Directorio creado:", opt$dir_o))
}

# Obtener la lista de archivos de genes en el directorio de entrada
gene_files <- list.files(opt$dir_i, full.names = TRUE)

# Función para realizar el análisis de enriquecimiento GO
run_enrichment <- function(gene_file, output_dir) {
  # Leer el archivo de genes
  genes <- readLines(gene_file)
  
  # Eliminar posibles espacios en blanco
  genes <- trimws(genes)
  
  # Realizar el análisis GO
  go_enrich <- enrichGO(
    gene = genes,
    OrgDb = org.Hs.eg.db,
    keyType = "SYMBOL",
    ont = "BP",  # Biological Process
    pAdjustMethod = "BH",  # Método de ajuste de p-valor Benjamini-Hochberg
    pvalueCutoff = 0.05
  )
  
  # Generar el gráfico de enriquecimiento
  dotplot(go_enrich)
  
  # Obtener el nombre del archivo sin extensión
  file_name <- tools::file_path_sans_ext(basename(gene_file))
  
  # Verificar si el directorio de salida existe, si no, crearlo
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
    print(paste("Directorio creado:", output_dir))
  }
  
  # Guardar el gráfico como imagen PNG
  output_file <- file.path(output_dir, paste0("func_anal_res_", file_name, ".png"))
  ggsave(output_file, width = 10, height = 8)
  
  print(paste("Gráfico guardado en:", output_file))
}

# Procesar cada archivo en el directorio de entrada
for (gene_file in gene_files) {
  run_enrichment(gene_file, opt$dir_o)
}

