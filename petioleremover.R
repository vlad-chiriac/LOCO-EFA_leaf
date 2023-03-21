#install.packages("BiocManager") 
#BiocManager::install("EBImage")
library(png)
library(EBImage)

#where petiole dataset is
pth <- "~/mydata/Github/dataset"
#creates new folder for second dataset
resultspth <- sub("dataset", "dataset2", pth)
dir.create(resultspth)
setwd(resultspth)

my_images <- list.files(pth,full.names=TRUE,pattern="*.*png")
my_images_short_names <- list.files(pth,full.names=FALSE,pattern="*.*png")

for (i in 1:(length(my_images))) {
  opnd <- opening(readPNG(my_images[i]), kern = makeBrush(33, shape='disc'))
  writePNG(opnd, my_images_short_names[i])
  cat("Now processing",my_images[i],"\n")
}
