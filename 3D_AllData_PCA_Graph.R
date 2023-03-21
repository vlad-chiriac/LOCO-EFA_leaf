#install.packages("devtools")
#library(devtools)
#devtools::install_github("cmartin/ggConvexHull")
library(scatterplot3d);library(rgl);library(ggfortify); library(ggplot2);library(ggConvexHull);library(plotly);library(factoextra)

csv <- as.data.frame(t(read.csv("~/mydata/Github/dataset/results/LiData.csv")))
csv <- csv[-1,-1]
csv <- csv[1:(length(csv)-35)]

colnames(csv) <- sub("V", "", colnames(csv))
csv$genus <- sub("([A-Za-z]+).*", "\\1", rownames(csv))
csv$species <- sub(".*?(\\w+)\\W+\\w+(\\W?)$", "\\1", rownames(csv))
csv$name <- paste(sub("([A-Za-z]+).*", "\\1", rownames(csv)), sub(".*?(\\w+)\\W+\\w+(\\W?)$", "\\1", rownames(csv)))

pc <- FactoMineR::PCA(csv[1:(length(csv)-3)],graph = FALSE)
scores <- as.data.frame(pc$svd$U)

#automatically names graph based on whether petiole is present or not
#this assumes you keep the original petioleremover script naming scheme, change it appropriately if need be
title <- "All species"
if (grepl("dataset2", pth)) {
  petiole <- "without"
} else {
  petiole <- "with"
}


plotx <- scores[,1]
ploty <- scores[,2]
plotz <- scores[,3]

scores$genus <- csv$genus
scores$species <- csv$species
scores$name <- csv$name

axisx <- paste0("PC1 ", round(pc$eig[,2][1], 2), "%")
axisy <- paste0("PC2 ", round(pc$eig[,2][2], 2), "%")
axisz <- paste0("PC3 ", round(pc$eig[,2][3], 2), "%")

graph <- plot_ly(scores, type = "mesh3d",x=plotx, y=ploty, z=plotz, color=scores$genus, opacity=0.1, alphahull=0, legendgroup=scores$genus, name=scores$genus, showlegend=TRUE) %>% plotly::layout(margin = list(t = 40),title = list(text=paste(title,'<br>','<sup>',petiole,'petiole','</sup>'),x = 0.15),scene = list(xaxis = list(title = axisx,range = c(min(plotx),max(plotx))), yaxis = list(title = axisy,range = c(min(ploty),max(ploty))), zaxis = list(title = axisz,range = c(min(plotz),max(plotz))),aspectmode='manual',aspectratio = list(x=16, y=16, z=16)))
graph <- add_trace(graph,opacity=1, x=plotx, y=ploty, z=plotz, type="scatter3d", mode="markers", color=scores$name,name = scores$name, marker = list(size = 2), legendgroup=scores$genus, showlegend=TRUE)
graph
htmlwidgets::saveWidget(graph, "C:/Users/vlad/OneDrive - Cardiff University/Year 3/BI3001/ShapeAnalysis/dataset2/results/graph/LiData3D.html")


