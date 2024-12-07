library(optparse)
library(igraph)

# Definir los argumentos de la línea de comandos
option_list <- list(
  make_option("--i", type = "character", help = "Archivo de interacción de proteínas en formato CSV.", metavar = "character"),
  make_option("--dir_res", type = "character", help = "Directorio para guardar el archivo de resumen de métricas.", metavar = "character"),
  make_option("--dir_img", type = "character", help = "Directorio para guardar las imágenes generadas.", metavar = "character"),
  make_option("--dir_genes", type = "character", help = "Directorio para guardar el archivo de genes destacados.", metavar = "character")
)

# Parsear los argumentos
opt <- parse_args(OptionParser(option_list = option_list))

# Verificar que se hayan proporcionado los argumentos requeridos
if (is.null(opt$i) || is.null(opt$dir_res) || is.null(opt$dir_img) || is.null(opt$dir_genes)) {
  stop("Todos los argumentos (--i, --dir_res, --dir_img, --dir_genes) son obligatorios.")
}

# Crear los directorios de salida si no existen
if (!dir.exists(opt$dir_res)) dir.create(opt$dir_res, recursive = TRUE)
if (!dir.exists(opt$dir_img)) dir.create(opt$dir_img, recursive = TRUE)
if (!dir.exists(opt$dir_genes)) dir.create(opt$dir_genes, recursive = TRUE)

# Rutas de salida
metrics_file <- file.path(opt$dir_res, "network_metrics.txt")
top_nodes_file <- file.path(opt$dir_genes, "top_nodes.txt")

# Cargar la red de interacciones
interaction_network <- read.csv(opt$i)

# Convertir la red de interacciones en un grafo de igraph
g <- graph_from_data_frame(interaction_network, directed = FALSE)

# Calcular métricas de la red
num_nodes <- gorder(g)
num_edges <- gsize(g)
degree_values <- degree(g)
average_degree <- mean(degree_values)
network_density <- edge_density(g)
dispersion <- 1 - network_density
avg_path_length <- mean_distance(g)
vertex_connectivity <- vertex_connectivity(g)
edge_connectivity <- edge_connectivity(g)
centrality_closeness <- closeness(g)
eigenvector_values <- eigen_centrality(g)$vector
clustering_values <- transitivity(g, type = "local")
betweenness_values <- betweenness(g)

# Crear un contador de calidad
quality_counter <- list()

update_quality_counter <- function(nodes, counter) {
  for (node in nodes) {
    if (node %in% names(counter)) {
      counter[[node]] <- counter[[node]] + 1
    } else {
      counter[[node]] <- 1
    }
  }
  return(counter)
}

get_top_5_nodes <- function(metric_values) {
  sorted_values <- sort(metric_values, decreasing = TRUE)
  top_5_nodes <- names(sorted_values[1:5])
  return(top_5_nodes)
}

# Obtener los nodos más destacados
top_degree_nodes <- get_top_5_nodes(degree_values)
top_betweenness_nodes <- get_top_5_nodes(betweenness_values)
top_eigenvector_nodes <- get_top_5_nodes(eigenvector_values)
top_clustering_nodes <- get_top_5_nodes(clustering_values)

# Actualizar el contador de calidad
quality_counter <- update_quality_counter(top_degree_nodes, quality_counter)
quality_counter <- update_quality_counter(top_betweenness_nodes, quality_counter)
quality_counter <- update_quality_counter(top_eigenvector_nodes, quality_counter)
quality_counter <- update_quality_counter(top_clustering_nodes, quality_counter)

# Guardar las métricas en un archivo de texto
cat("Número de nodos:", num_nodes, "\n", file = metrics_file)
cat("Número de aristas:", num_edges, "\n", file = metrics_file, append = TRUE)
cat("Promedio de grado:", average_degree, "\n", file = metrics_file, append = TRUE)
cat("Densidad de la red:", network_density, "\n", file = metrics_file, append = TRUE)
cat("Dispersión de la red:", dispersion, "\n", file = metrics_file, append = TRUE)
cat("Longitud promedio de caminos:", avg_path_length, "\n", file = metrics_file, append = TRUE)
cat("Conectividad de nodos:", vertex_connectivity, "\n", file = metrics_file, append = TRUE)
cat("Conectividad de aristas:", edge_connectivity, "\n", file = metrics_file, append = TRUE)

# Ordenar los genes por calidad y guardar los mejores 5 en un archivo
top_quality_genes <- names(sort(unlist(quality_counter), decreasing = TRUE)[1:5])
cat(top_quality_genes, sep = "\n", file = top_nodes_file)

# Crear las representaciones gráficas
png(file = file.path(opt$dir_img, "basic_network.png"))
plot(g, vertex.size = 5, vertex.label.cex = 0.7, edge.arrow.size = 0.5, main = "Red de Interacciones Básica")
dev.off()

png(file = file.path(opt$dir_img, "network_by_degree.png"))
plot(g, vertex.size = degree(g) / 2, edge.arrow.size = 0.7, vertex.label.cex = 0.8, main = "Red de Interacciones por Grado")
dev.off()

png(file = file.path(opt$dir_img, "fr_layout.png"))
layout <- layout_with_fr(g)
plot(g, layout = layout, vertex.color = "skyblue", vertex.size = 5, edge.width = 0.5, main = "Layout de Fruchterman-Reingold")
dev.off()

png(file = file.path(opt$dir_img, "circular_layout.png"))
circular_layout <- layout_in_circle(g)
plot(g, layout = circular_layout, vertex.color = "lightgreen", vertex.size = 5, vertex.label.cex = 0.8, edge.width = 0.5, main = "Layout Circular")
dev.off()

png(file = file.path(opt$dir_img, "no_labels.png"))
plot(g, vertex.color = "orange", vertex.size = 5, vertex.label = NA, edge.width = 0.5, main = "Red sin Etiquetas")
dev.off()

cat("Archivos generados en los directorios especificados.\n")




