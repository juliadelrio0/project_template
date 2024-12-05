# Cargar las bibliotecas necesarias
library(igraph)
library(ggraph)

# Función para calcular la modularidad de un clustering
calculate_modularity <- function(graph, communities) {
  modularity(communities, graph = graph)
}

# Función para generar la visualización del grafo
save_graph_plot <- function(graph, clusters, filename) {
  # Asignar colores a los clusters
  V(graph)$color <- rainbow(length(unique(clusters)))[clusters]
  
  # Guardar la visualización del grafo
  png(filename)
  plot(graph, vertex.size=5, vertex.label=NA, main="Clustering")
  dev.off()
}

# Función para generar el dendrograma
save_dendrogram <- function(clustering, filename) {
  dendrogram <- as.dendrogram(clustering)
  png(filename)
  plot(dendrogram, main="Dendrogram of Clustering")
  dev.off()
}

# Función principal que recibe el archivo CSV como argumento
main <- function(input_file, output_file) {
  # Leer el archivo CSV
  interactions <- read.csv(input_file, header = TRUE)
  
  # Crear el grafo
  graph <- graph_from_data_frame(interactions, directed = FALSE)
  
  # Aplicar los métodos de clustering y calcular la modularidad
  results <- list()
  clustering_graphs <- list()
  
  # Clustering por Edge Betweenness
  edge_betweenness_clustering <- edge_betweenness.community(graph)
  edge_betweenness_modularity <- calculate_modularity(graph, edge_betweenness_clustering)
  results$Edge_Betweenness <- list(clusters = membership(edge_betweenness_clustering), modularity = edge_betweenness_modularity)
  clustering_graphs$Edge_Betweenness <- edge_betweenness_clustering
  
  # Clustering por Walktrap
  walktrap_clustering <- walktrap.community(graph)
  walktrap_modularity <- calculate_modularity(graph, walktrap_clustering)
  results$Walktrap <- list(clusters = membership(walktrap_clustering), modularity = walktrap_modularity)
  clustering_graphs$Walktrap <- walktrap_clustering
  
  # Clustering por Fast Greedy
  fast_greedy_clustering <- fastgreedy.community(graph)
  fast_greedy_modularity <- calculate_modularity(graph, fast_greedy_clustering)
  results$Fast_Greedy <- list(clusters = membership(fast_greedy_clustering), modularity = fast_greedy_modularity)
  clustering_graphs$Fast_Greedy <- fast_greedy_clustering
  
  # Clustering por Infomap
  infomap_clustering <- infomap.community(graph)
  infomap_modularity <- calculate_modularity(graph, infomap_clustering)
  results$Infomap <- list(clusters = membership(infomap_clustering), modularity = infomap_modularity)
  clustering_graphs$Infomap <- infomap_clustering
  
  # Clustering por Label Propagation
  label_propagation_clustering <- cluster_label_prop(graph)
  label_propagation_modularity <- calculate_modularity(graph, label_propagation_clustering)
  results$Label_Propagation <- list(clusters = membership(label_propagation_clustering), modularity = label_propagation_modularity)
  clustering_graphs$Label_Propagation <- label_propagation_clustering
  
  # Encontrar el mejor clustering basado en la modularidad
  best_algorithm <- names(which.max(sapply(results, function(x) x$modularity)))
  best_modularity <- max(sapply(results, function(x) x$modularity))
  
  # Crear directorios para guardar las imágenes
  dir.create("report", showWarnings = FALSE)
  dir.create("report/figures", showWarnings = FALSE)
  
  # Guardar el grafo del mejor clustering
  best_clustering <- clustering_graphs[[best_algorithm]]
  save_graph_plot(graph, membership(best_clustering), paste0("report/figures/best_", best_algorithm, ".png"))
  
  # Guardar el dendrograma del mejor clustering
  save_dendrogram(best_clustering, paste0("report/figures/dendrogram_", best_algorithm, ".png"))
  
  # Crear la tabla de genes y clusters para el mejor algoritmo
  clusters <- membership(best_clustering)
  gene_names <- interactions$Gene1  # Asumiendo que la columna del CSV tiene nombres de genes
  cluster_table <- data.frame(Gene = gene_names, Cluster = clusters)
  
  # Guardar la tabla en el archivo de salida
  write.table(cluster_table, file = output_file, row.names = FALSE, sep = "\t", quote = FALSE)
  
  # Guardar los resultados en un archivo de texto
  sink(output_file, append = TRUE)
  cat("\nMejor algoritmo de clustering:", best_algorithm, "\n")
  cat("Modularidad máxima:", best_modularity, "\n\n")
  
  for (algorithm in names(results)) {
    cat(paste(algorithm, "clustering:\n"))
    cat("Modularidad:", results[[algorithm]]$modularity, "\n")
    cat("Clusters:\n")
    print(results[[algorithm]]$clusters)
    cat("\n")
  }
  
  sink()  # Finaliza la escritura en el archivo
}

# Llamar a la función principal con los argumentos de entrada y salida
args <- commandArgs(trailingOnly = TRUE)
input_file <- args[1]
output_file <- args[2]
main(input_file, output_file)
