library(ggfortify); library(ggplot2);library(ggConvexHull);library(plotly);library(factoextra)
LiData <- "~/mydata/Github/dataset/results/LiData.csv"
setwd("C:/Users/vlad/OneDrive - Cardiff University/Year 3/BI3001/ShapeAnalysis/dataset/results/graph")

petiole <- c()

#automatically names graph based on whether petiole is present or not
#this assumes you keep the original petioleremover script naming scheme, change it appropriately if need be
if (grepl("dataset2", pth)) {
  petiole <- "without"
} else {
  petiole <- "with"
}

csv <- as.data.frame(t(read.csv(pth)))
csv <- csv[-1,-1]
csv <- csv[1:(length(csv)-35)]
colnames(csv) <- sub("V", "", colnames(csv))
csv$genus <- sub("([A-Za-z]+).*", "\\1", rownames(csv))
csv$species <- sub(".*?(\\w+)\\W+\\w+(\\W?)$", "\\1", rownames(csv))
csv$name <- paste(sub("([A-Za-z]+).*", "\\1", rownames(csv)), sub(".*?(\\w+)\\W+\\w+(\\W?)$", "\\1", rownames(csv)))

pc <- FactoMineR::PCA(csv[1:(length(csv)-3)],graph = FALSE)

totvar <- paste0(round(pc$eig[,2][1], 2) + round(pc$eig[,2][2], 2) + round(pc$eig[,2][3], 2),"% total variance explained")

graph <- fviz_pca_ind(pc,label = 'none',habillage = as.factor(csv$name),addEllipses = TRUE,ellipse.level = 0.90,mean.point = FALSE, title = csv$genus[1], subtitle = paste(petiole, "petiole"),legend.title = "Species") 
#graph
#ggsave(filename = my_files_short[i], device = jpeg, width = 8, height = 6)
htmlgraph <- ggplotly(graph) %>% layout(margin = list(t = 40), title = list(text = paste("All species",totvar,'<br>','<sup>',petiole,'petiole','</sup>'), x = 0.15))
for (k in 1:length(htmlgraph$x$data)){
  if (!is.null(htmlgraph$x$data[[k]]$name)){
    htmlgraph$x$data[[k]]$name = gsub('^\\(|,\\d+\\)$', '', htmlgraph$x$data[[k]]$name)
  }
}  
htmlgraph
htmlwidgets::saveWidget(htmlgraph, "LiData.html")





