#needed by devtools
#install.packages("cli")
#needed to build cellshape from source
#install.packages("devtools")
#the cellshape library contains the functions to find the contour and shape descriptors
#devtools::install_bitbucket("stan_maree/cellshape")
#the png library is required to read in png pictures
#install.packages("png")


#load in the required packages
library(cellshape)
library(png)
#path to the dataset
pth <- "~/mydata/Github/dataset/"
#create the results path and set the working directory to it, so that the images are output there
resultspth <- paste(pth, "results", sep="")
dir.create(resultspth)
setwd(resultspth)

my_images <- list.files(pth,full.names=TRUE,pattern="*.*png")
my_images_short_names <- list.files(pth,full.names=FALSE,pattern="*.*png")
my_images_short_names <- sub(".png", "", my_images_short_names)
contour <- c()
shapedescriptors <- c()

for (i in 1:length(my_images)) {
  #print where we are in the analysis, then you know how long to wait; "\n" means finish the line and go to the next line
  cat("Now analysing",my_images[i],"\n")
  #read in this image in our list of images
  img<-readPNG(my_images[i])
  #determine the contour
  tmp<-array(CellContour(as.matrix(img)),dim=c(100000,4))
  #assign the contour to the contour list, after determining the number of contour points that form the contour
  contour[[i]]<-array(tmp,dim=c(tmp[1][1],4))
  #assign the shape descriptors to shapedescriptors[[i]]
  shapedescriptors[[i]]<-array(LOCOEFA(as.matrix(contour[[i]])),dim=c(52,7))
  #print the Li values
  print(shapedescriptors[[i]][,2])
}
#convert shapedescriptors to a spreadsheet
LiData <-data.frame(lapply(shapedescriptors, `[`,,2),row.names=shapedescriptors[[1]][,1])
#name the columns the images' names
colnames(LiData) <- my_images_short_names
#remove the 0 rows
LiData = LiData[as.logical(rowSums(LiData != 0)), ]
#export the results to one massive file
write.csv(LiData, file = "AllData.csv")

#split LiData by species
LiDataSpecies <- split.default(LiData, sub(" \\d\\d", "", names(LiData)))
#split LiData by genus
LiDataGenus <- split.default(LiData, sub(" ([A-Za-z]+).*\\d\\d", "", names(LiData)))

#create empty variable that will contain all the species' averages
LiDataAVGs <- c()

#create empty list that will contain all average names
avgnames <- c()

#loop that goes through each database contained within the nested list "LiDataSpecies" and creates an average for the entire species
for (i in 1:(length(names(LiDataSpecies)))) {
  avgname <- paste(names(LiDataSpecies[i]), "avg") #create temporary column name that will later be replaced
  LiDataSpecies[[i]]$Average <- rowMeans(LiDataSpecies[[i]])  #add an average column to each species' results
  names(LiDataSpecies[[i]])[names(LiDataSpecies[[i]]) == "Average"] <- avgname      #rename the average column to the species' name
  LiDataAVGs[[i]] <- LiDataSpecies[[i]][, avgname]      #add all average columns to a list
  LiDataAVGs <- data.frame(LiDataAVGs)            #make the list back into a table
  avgnames <- append(avgnames, avgname)           #add each average name to a list
  colnames(LiDataAVGs) <- avgnames                #set the column names to the average names
}
#remove the 0 rows
LiDataAVGs = LiDataAVGs[as.logical(rowSums(LiData != 0)), ]
#export AVGs by genus into own CSV
LiDataSpeciesAVGs <- split.default(LiDataAVGs, sub("([A-Za-z]+).*", "\\1", names(LiDataAVGs)))
names(LiDataSpeciesAVGs) <- gsub("([A-Za-z]+)", "\\1 avgs", names(LiDataSpeciesAVGs))
sapply(names(LiDataSpeciesAVGs), function (x) write.csv(LiDataSpeciesAVGs[[x]], file=paste(x, "csv", sep=".")))
#export a CSV containing only the AVGs
write.csv(LiDataAVGs, file = "AllDataAVGs.csv")
#export each species' results' to its own csv
sapply(names(LiDataSpecies), function (x) write.csv(LiDataSpecies[[x]], file=paste(x, "csv", sep=".")))
#export each genus' results to its own csv
sapply(names(LiDataGenus), function (x) write.csv(LiDataGenus[[x]], file=paste(x, "csv", sep=".")))

#sapply(names(LiDataSpeciesAVGs), function (x) write.csv(LiDataSpeciesAVGs[[x]], file=paste(x, "csv", sep="."))) #outputs avgs to own csv, unindent if it seems useful

outlines <- lapply(contour, `[`,,c(2,3))
maxlength<-max(sapply(outlines, `nrow`))
OutlineData<-data.frame(lapply(outlines,function(x) rbind(x,matrix(NA,nrow=maxlength-nrow(x),ncol=2))))
my_images_short_names_twice <- rep(my_images_short_names,each=2)
my_images_short_names_twice <- paste(my_images_short_names_twice,c("X","Y"),sep=" ")
colnames(OutlineData) <- my_images_short_names_twice
write.csv(OutlineData, file = "OutlineData_test.csv",na="")