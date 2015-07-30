library(pixmap)

# Load the mean and PCs of the pixel vectors from
# the dataset.
mean_PCs <- read.csv("PCs.csv")
mean <- mean_PCs[,1]
PCs <- mean_PCs[,-1]

# Extract the desired principal components of all 
# image files.
flist <- list.files("data/faces/")
for (f in flist){
  pix <- as.vector(getChannels(read.pnm(paste0("data/faces/", f))))
  pix_cmp <- round(t(PCs) %*% (pix - mean), 3)
  f_cmp <- sub(".pgm", ".csv", f)
  write.csv(pix_cmp, paste0("data/faces_cmp/", f_cmp),
            row.names=FALSE)
}
