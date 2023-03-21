library(MASS)
pth <- "C:/Users/vlad/OneDrive - Cardiff University/Year 3/BI3001/ShapeAnalysis/dataset2/results/LiData.csv"
#pth2 <- "C:/Users/vlad/OneDrive - Cardiff University/Year 3/BI3001/ShapeAnalysis/dataset2/results/Acer.csv"
genus = FALSE

csv <- as.data.frame(t(read.csv(pth)))
csv <- csv[-1,-1]
colnames(csv) <- sub("V", "", colnames(csv))

#csv2 <- as.data.frame(t(read.csv(pth2)))
#csv2 <- csv2[-1,-1]
#csv2 <- csv2[1:(length(csv2)-35)]
#colnames(csv2) <- sub("V", "", colnames(csv2))

if (genus) {
  csv$name <- sub("([A-Za-z]+).*", "\\1", rownames(csv))
} else{
  csv$name <- paste(sub("([A-Za-z]+).*", "\\1", rownames(csv)), sub(".*?(\\w+)\\W+\\w+(\\W?)$", "\\1", rownames(csv)))
  #csv2$name <- paste(sub("([A-Za-z]+).*", "\\1", rownames(csv2)), sub(".*?(\\w+)\\W+\\w+(\\W?)$", "\\1", rownames(csv2)))
}

#csv$genus <- sub("([A-Za-z]+).*", "\\1", rownames(csv))
#csv$name <- paste(sub("([A-Za-z]+).*", "\\1", rownames(csv)), sub(".*?(\\w+)\\W+\\w+(\\W?)$", "\\1", rownames(csv)))

ind <- csv
ind[1:15] <- scale(ind[1:15])

#ind2 <- csv2
#ind2[1:15] <- scale(ind2[1:15])

round(apply(ind[1:15], 2, mean))
apply(ind[1:15], 2, sd)

sampling <- sample(c(TRUE, FALSE), nrow(ind), replace=TRUE, prob=c(0.7,0.3))
train <- ind[sampling,]
test <- ind[!sampling,] 
name <- train$name
model <- lda(name~.,train[1:16])

prd <- predict(model, test)
#class: The predicted class
#posterior: The posterior probability that an observation belongs to each class
#x: The linear discriminants
#prd

mean(prd$class==test$name)*100
mean(sub("([A-Za-z]+).*", "\\1", prd$class)==sub("([A-Za-z]+).*", "\\1", test$name))*100


predictions <- test[51:52]
predictions$correct <- predictions$name==predictions$prediction
predictions$gnsprediction <- sub(" ([A-Za-z]+)", "", predictions$prediction)
predictions$genus <- sub("\\.([A-Za-z]+)\\.\\d\\d", "", rownames(predictions))
predictions$gnscorrect <- predictions$genus==predictions$gnsprediction

gnslist <- split(predictions[4:6], predictions$genus)

spclist <- split(predictions[1:3], predictions$name)

gnspct <- list()
spcpct <- list()
for (i in 1:length(spclist)) {
  spcpct[i] <- paste(spclist[[i]]$name, mean(spclist[[i]]$correct)*100)
}

for (i in 1:length(gnslist)) {
  gnspct[i] <- paste(gnslist[[i]]$genus, mean(gnslist[[i]]$gnscorrect)*100)
}
gnscsv <- as.data.frame(gnspct)
gnscsv <- t(gnscsv)
spccsv <- as.data.frame(spcpct)
spccsv <- t(spccsv)
rownames(gnscsv) <- sub("X\\.", "", rownames(gnscsv))
rownames(gnscsv) <- sub("([A-Za-z]+).*", "\\1", rownames(gnscsv))
gnscsv[,1] <- sub("([A-Za-z]+)", "", gnscsv[,1])


rownames(spccsv) <- sub("X\\.", "", rownames(spccsv))
rownames(spccsv) <- sub("\\.", " ", rownames(spccsv))
rownames(spccsv) <- sub("\\.", " ", rownames(spccsv))
rownames(spccsv) <- sub(" ([^[:alpha:]]+)\\.([^[:alpha:]]+)", "", rownames(spccsv))
spccsv[,1] <- sub("([A-Za-z]+) ([A-Za-z]+) ", "", spccsv[,1])

write.csv(gnscsv, "Genus prediction accuracy.csv")
write.csv(spccsv, "Species prediction accuracy.csv")


#ggord(model, train$name)
#lda_plot <- cbind(train, predict(model)$x)
#ggplot(lda_plot, aes(LD1, LD2, color=name)) +
#  geom_point(aes(color = name)) +
#  stat_ellipse(geom = "polygon",aes(fill = name), alpha = 0.25) +
#  theme(legend.position = "none")

#lda_plotly <- plot_ly(data = lda_plot,type = "scatter", mode="markers",color = lda_plot$name,legendgroup = lda_plot$name, x=lda_plot$LD1, y=lda_plot$LD2) %>% 
#  plotly::layout(title='LDA prediction plot')
#lda_plotly