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
centrality_closeness <- closeness(g)  # Centralidad de cercanía

# Centralidad de autovector
eigenvector_values <- eigen_centrality(g)$vector  # Usando eigen_centrality

# Coeficiente de agrupamiento
clustering_values <- transitivity(g, type = "local")

# Centralidad de intermediación
betweenness_values <- betweenness(g)  # Centralidad de intermediación

# Crear un contador de calidad
quality_counter <- list()  # Diccionario para contar las veces que cada gen aparece en las mejores métricas

# Función para obtener los top 5 nodos basados en los valores de las métricas
get_top_5_values <- function(metric_values) {
  sorted_values <- sort(metric_values, decreasing = TRUE)  # Ordenar de mayor a menor
  top_5_values <- sorted_values[1:5]  # Obtener los 5 primeros valores
  return(top_5_values)
}

# Función para obtener los nodos correspondientes a los top 5 valores
get_top_5_nodes <- function(metric_values) {
  sorted_values <- sort(metric_values, decreasing = TRUE)  # Ordenar de mayor a menor
  top_5_nodes <- names(sorted_values[1:5])  # Obtener los 5 primeros nodos
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

# Función para actualizar el contador de calidad
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

# Actualizar el contador de calidad con los top nodos
quality_counter <- update_quality_counter(top_degree_nodes, quality_counter)
quality_counter <- update_quality_counter(top_betweenness_nodes, quality_counter)
quality_counter <- update_quality_counter(top_eigenvector_nodes, quality_counter)
quality_counter <- update_quality_counter(top_clustering_nodes, quality_counter)

# Diámetro de la red
network_diameter <- diameter(g)

# Asortatividad
assortativity_value <- assortativity(g, values = degree_values, directed = FALSE)

# Guardar las métricas en un archivo de texto (sin nombres de genes, solo los valores)
cat("Número de nodos:", num_nodes, "\n", file = metrics_file)
cat("Número de aristas:", num_edges, "\n", file = metrics_file, append = TRUE)
cat("Promedio de grado:", average_degree, "\n", file = metrics_file, append = TRUE)
cat("Densidad de la red:", network_density, "\n", file = metrics_file, append = TRUE)

# Añadir valores de las métricas para los primeros 5 nodos
cat("Centralidad de cercanía (primeros 5 nodos):", paste(top_degree_values, collapse = " "), "\n", file = metrics_file, append = TRUE)
cat("Centralidad de autovector (primeros 5 nodos):", paste(top_eigenvector_values, collapse = " "), "\n", file = metrics_file, append = TRUE)
cat("Coeficiente de agrupamiento (primeros 5 nodos):", paste(top_clustering_values, collapse = " "), "\n", file = metrics_file, append = TRUE)
cat("Centralidad de intermediación (primeros 5 nodos):", paste(top_betweenness_values, collapse = " "), "\n", file = metrics_file, append = TRUE)
cat("Diámetro de la red:", network_diameter, "\n", file = metrics_file, append = TRUE)
cat("Asortatividad:", assortativity_value, "\n", file = metrics_file, append = TRUE)

# Estudio de la distribución del grado
png(file = paste0(plot_directory, "/degree_distribution.png"))
hist(degree_values, breaks = 30, col = "lightblue", main = "Distribución del Grado", xlab = "Grado", ylab = "Frecuencia")
dev.off()

# Crear los gráficos
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

# Ordenar los genes por calidad y seleccionar los 5 mejores
top_quality_genes <- names(sort(unlist(quality_counter), decreasing = TRUE)[1:5])

# Guardar los nodos destacados en un archivo de texto
cat("Top genes por calidad potencial:\n", file = top_nodes_file)
cat(top_quality_genes, sep = "\n", file = top_nodes_file, append = TRUE)

cat("Gráficas generadas en el directorio de imágenes.\n")

