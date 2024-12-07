# Cargar las bibliotecas necesarias
library(igraph)
library(optparse)

# Función para calcular la modularidad de un clustering
calculate_modularity <- function(graph, communities) {
  modularity(communities, graph = graph)
}

# Función para generar la visualización del dendograma de comunidades
save_dendrogram_plot <- function(graph, clustering, filename) {
  # Crear el dendograma de la jerarquía de comunidades
  dendrogram <- as.dendrogram(clustering)
  
  # Guardar el dendograma
  png(filename)
  plot(dendrogram, main = "Dendograma de la Jerarquía de Comunidades")
  dev.off()
}

# Función para generar la visualización con clusters coloreados y una leyenda
save_colored_clusters_plot <- function(graph, clusters, filename) {
  # Asignar colores a los clusters
  unique_clusters <- unique(clusters)
  cluster_colors <- rainbow(length(unique_clusters))
  V(graph)$color <- cluster_colors[clusters]
  
  # Guardar la visualización con clusters coloreados
  png(filename)
  plot(
    graph, 
    vertex.size = 5, 
    vertex.label = NA, 
    main = "Visualización con clusters coloreados"
  )
  legend(
    "topright", 
    legend = paste("Cluster", unique_clusters), 
    col = cluster_colors, 
    pch = 20, 
    bty = "n", 
    cex = 0.8
  )
  dev.off()
}

# Función principal que recibe los directorios y el archivo CSV como argumento
main <- function(input_file, dirimg, dirgenclus, dirres) {
  set.seed(42)  # Establecer una semilla para garantizar la reproducibilidad
  
  # Leer el archivo CSV
  interactions <- read.csv(input_file, header = TRUE)
  
  # Crear el grafo
  graph <- graph_from_data_frame(interactions, directed = FALSE)
  
  # Aplicar los métodos de clustering y calcular la modularidad
  results <- list()
  clustering_graphs <- list()
  
  # Clustering por Edge Betweenness
  edge_betweenness_clustering <- cluster_edge_betweenness(graph)
  edge_betweenness_modularity <- calculate_modularity(graph, edge_betweenness_clustering)
  results$Edge_Betweenness <- list(clusters = membership(edge_betweenness_clustering), modularity = edge_betweenness_modularity)
  clustering_graphs$Edge_Betweenness <- edge_betweenness_clustering
  
  # Clustering por Walktrap
  walktrap_clustering <- cluster_walktrap(graph)
  walktrap_modularity <- calculate_modularity(graph, walktrap_clustering)
  results$Walktrap <- list(clusters = membership(walktrap_clustering), modularity = walktrap_modularity)
  clustering_graphs$Walktrap <- walktrap_clustering
  
  # Clustering por Fast Greedy
  fast_greedy_clustering <- cluster_fast_greedy(graph)
  fast_greedy_modularity <- calculate_modularity(graph, fast_greedy_clustering)
  results$Fast_Greedy <- list(clusters = membership(fast_greedy_clustering), modularity = fast_greedy_modularity)
  clustering_graphs$Fast_Greedy <- fast_greedy_clustering
  
  # Clustering por Infomap
  infomap_clustering <- cluster_infomap(graph)
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
  
  # Crear directorios para guardar las imágenes y archivos de genes
  dir.create(file.path(dirimg), showWarnings = FALSE)
  dir.create(file.path(dirgenclus), showWarnings = FALSE)
  
  # Guardar tres visualizaciones diferentes del grafo
  best_clustering <- clustering_graphs[[best_algorithm]]
  clusters <- membership(best_clustering)
  
  # Sustituir la visualización básica por un dendograma con el mejor algoritmo
  save_dendrogram_plot(graph, best_clustering, file.path(dirimg, paste0("dendrogram_", best_algorithm, ".png")))
  
  # Guardar otras visualizaciones
  save_colored_clusters_plot(graph, clusters, file.path(dirimg, paste0("colored_", best_algorithm, ".png")))
  
  # Guardar los genes de cada cluster en archivos separados
  for (i in unique(clusters)) {
    cluster_genes <- names(clusters[clusters == i])
    write.table(cluster_genes, file = file.path(dirgenclus, paste0("cluster_", i, ".txt")), row.names = FALSE, col.names = FALSE, quote = FALSE)
  }
  
  # Guardar los resultados de las clusterizaciones en un archivo separado
  sink(file.path(dirres, "clusters_info.txt"), append = TRUE)
  cat("\nMejor algoritmo de clustering:", best_algorithm, "\n")
  
  for (algorithm in names(results)) {
    cat(paste(algorithm, "clustering:\n"))
    cat("Modularidad:", results[[algorithm]]$modularity, "\n")
    num_clusters <- length(unique(results[[algorithm]]$clusters))  # Número de clusters
    cat("Número de clusters:", num_clusters, "\n")
    # Incluir el número de clusters
    cat("Clusters:\n")
    print(results[[algorithm]]$clusters)
    cat("\n")
  }
  sink()  # Finaliza la escritura en el archivo
}

# Configuración de argumentos con optparse
option_list <- list(
  make_option(c("-r", "--red"), type = "character", help = "Archivo CSV con la red de interacción de proteínas"),
  make_option(c("-d", "--dirimg"), type = "character", help = "Directorio para guardar las imágenes generadas"),
  make_option(c("-g", "--dirgenclus"), type = "character", help = "Directorio para guardar los archivos con los genes por cluster"),
  make_option(c("-s", "--dirres"), type = "character", help = "Directorio para guardar el resumen de las clusterizaciones")
)

opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

# Llamar a la función principal con los directorios y archivo de entrada como argumentos
main(opt$red, opt$dirimg, opt$dirgenclus, opt$dirres)