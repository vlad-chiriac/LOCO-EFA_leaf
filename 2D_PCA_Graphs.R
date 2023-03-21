library(ggfortify); library(ggplot2);library(ggConvexHull);library(plotly);library(factoextra)
pth <- "~/mydata/Github/dataset/results" #make sure this doesn't end in /
resultspth <- paste(pth, "graph", sep="/")
dir.create(resultspth)
setwd(resultspth)

my_files_short <- list.files(pth,full.names=FALSE,pattern="([A-Za-z]+)\\.csv")
my_files_short <- sub("([A-Za-z]+).*", "\\1.csv", my_files_short)
my_files_short <- unique(lapply(my_files_short, sort))
my_files_short <- unlist(my_files_short)
my_files <- paste(pth,my_files_short, sep = "/")
my_files_short2 <- sub("\\.csv", "\\1.html", my_files_short)



petiole <- c()

if (grepl("dataset2", pth)) {
  petiole <- "without"
} else {
  petiole <- "with"
}


for (i in 1:length(my_files)) {
  if (grepl("OutlineData", my_files[i])) {
    next
  }
  csv <- as.data.frame(t(read.csv(my_files[i])))
  csv <- csv[-1,-1]
  csv <- csv[1:(length(csv)-35)]
  colnames(csv) <- sub("V", "", colnames(csv))
  csv$genus <- sub("([A-Za-z]+).*", "\\1", rownames(csv))
  csv$species <- sub(".*?(\\w+)\\W+\\w+(\\W?)$", "\\1", rownames(csv))
  csv$name <- paste(sub("([A-Za-z]+).*", "\\1", rownames(csv)), sub(".*?(\\w+)\\W+\\w+(\\W?)$", "\\1", rownames(csv)))
  if (length(unique(csv$species))==1) {next} #skip single species files cause they break the graph code
  pc <- FactoMineR::PCA(csv[1:(length(csv)-3)],graph = FALSE)
  graph <- fviz_pca_biplot(pc,label = 'var',col.var='black',habillage = as.factor(csv$name),addEllipses = TRUE,ellipse.level = 0.90,mean.point = FALSE, title = csv$genus[1], subtitle = paste(petiole, "petiole"),legend.title = "Species") 
  graph
  ggsave(filename = sub("([A-Za-z]+).*", "\\1.png", my_files_short)[i], device = jpeg, width = 8, height = 6)
  htmlgraph <- ggplotly(graph) %>% layout(margin = list(t = 40), title = list(text = paste(csv$genus[1],'<br>','<sup>',petiole,'petiole','</sup>'), x = 0.15))
  for (k in 1:length(htmlgraph$x$data)){
    if (!is.null(htmlgraph$x$data[[k]]$name)){
      htmlgraph$x$data[[k]]$name = gsub('^\\(|,\\d+\\)$', '', htmlgraph$x$data[[k]]$name)
    }
  }
  htmlgraph
  htmlwidgets::saveWidget(htmlgraph, sub("([A-Za-z]+).*", "\\1.html", my_files_short)[i])
  cat(my_files_short2[i],"finished \n")
}



