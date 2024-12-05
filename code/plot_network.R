library(igraph)

# Leer argumentos desde la línea de comandos
args <- commandArgs(trailingOnly = TRUE)
interaction_file <- args[1]   # Archivo de interacciones
plot_directory <- args[2]     # Directorio para guardar imágenes
results_directory <- args[3]  # Directorio para guardar métricas y nodos destacados

# Rutas de salida
metrics_file <- paste0(results_directory, "/network_metrics.txt")
top_nodes_file <- paste0(results_directory, "/top_nodes.txt")

# Cargar la red de interacciones
interaction_network <- read.csv(interaction_file)

# Convertir la red de interacciones en un grafo de igraph
g <- graph_from_data_frame(interaction_network, directed = FALSE)

# Calcular métricas de la red
num_nodes <- gorder(g)  # Número de nodos
num_edges <- gsize(g)   # Número de aristas
degree_values <- degree(g)  # Grado de los nodos
average_degree <- mean(degree_values)  # Promedio de grado
network_density <- edge_density(g)  # Densidad de la red
dispersion <- 1 - network_density  # Dispersión de la red
avg_path_length <- mean_distance(g)  # Longitud promedio de caminos
vertex_connectivity <- vertex_connectivity(g)  # Conectividad de nodos
edge_connectivity <- edge_connectivity(g)  # Conectividad de aristas

# Centralidad de cercanía
centrality_closeness <- closeness(g)

# Centralidad de autovector
eigenvector_values <- eigen_centrality(g)$vector

# Coeficiente de agrupamiento
clustering_values <- transitivity(g, type = "local")

# Centralidad de intermediación
betweenness_values <- betweenness(g)

# Crear un contador de calidad
quality_counter <- list()

# Función para obtener los top 5 valores y nodos
get_top_5_values <- function(metric_values) {
  sorted_values <- sort(metric_values, decreasing = TRUE)  # Ordenar de mayor a menor
  top_5_values <- sorted_values[1:5]
  return(top_5_values)
}

get_top_5_nodes <- function(metric_values) {
  sorted_values <- sort(metric_values, decreasing = TRUE)
  top_5_nodes <- names(sorted_values[1:5])
  return(top_5_nodes)
}

# Obtener los top 5 valores y nodos para cada métrica
top_degree_values <- get_top_5_values(degree_values)
top_degree_nodes <- get_top_5_nodes(degree_values)

top_betweenness_values <- get_top_5_values(betweenness_values)
top_betweenness_nodes <- get_top_5_nodes(betweenness_values)

top_eigenvector_values <- get_top_5_values(eigenvector_values)
top_eigenvector_nodes <- get_top_5_nodes(eigenvector_values)

top_clustering_values <- get_top_5_values(clustering_values)
top_clustering_nodes <- get_top_5_nodes(clustering_values)

# Actualizar el contador de calidad
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

# Guardar los top 5 valores para métricas seleccionadas
cat("Centralidad de cercanía (primeros 5 valores):", paste(get_top_5_values(centrality_closeness), collapse = " "), "\n", file = metrics_file, append = TRUE)
cat("Centralidad de autovector (primeros 5 valores):", paste(top_eigenvector_values, collapse = " "), "\n", file = metrics_file, append = TRUE)
cat("Coeficiente de agrupamiento (primeros 5 valores):", paste(top_clustering_values, collapse = " "), "\n", file = metrics_file, append = TRUE)
cat("Centralidad de intermediación (primeros 5 valores):", paste(top_betweenness_values, collapse = " "), "\n", file = metrics_file, append = TRUE)

# Ordenar los genes por calidad y guardar los mejores 5
top_quality_genes <- names(sort(unlist(quality_counter), decreasing = TRUE)[1:5])

cat("Top genes por calidad potencial:\n", file = top_nodes_file)
cat(top_quality_genes, sep = "\n", file = top_nodes_file, append = TRUE)

# Crear las representaciones gráficas
# Gráfico básico
png(file = paste0(plot_directory, "/basic_network.png"))
plot(g, vertex.size = 5, vertex.label.cex = 0.7, edge.arrow.size = 0.5, main = "Red de Interacciones Básica")
dev.off()

# Gráfico por grado de los nodos
png(file = paste0(plot_directory, "/network_by_degree.png"))
plot(g, vertex.size = degree(g) / 2, edge.arrow.size = 0.7, vertex.label.cex = 0.8, main = "Red de Interacciones por Grado")
dev.off()

# Gráfico con el layout de Fruchterman-Reingold
png(file = paste0(plot_directory, "/fr_layout.png"))
layout <- layout_with_fr(g)
plot(g, layout = layout, vertex.color = "skyblue", vertex.size = 5, edge.width = 0.5, main = "Layout de Fruchterman-Reingold")
dev.off()

# Gráfico con layout circular
png(file = paste0(plot_directory, "/circular_layout.png"))
circular_layout <- layout_in_circle(g)
plot(g, layout = circular_layout, vertex.color = "lightgreen", vertex.size = 5, vertex.label.cex = 0.8, edge.width = 0.5, main = "Layout Circular")
dev.off()

# Gráfico sin etiquetas
png(file = paste0(plot_directory, "/no_labels.png"))
plot(g, vertex.color = "orange", vertex.size = 5, vertex.label = NA, edge.width = 0.5, main = "Red sin Etiquetas")
dev.off()

cat("Gráficas generadas en el directorio de imágenes.\n")


