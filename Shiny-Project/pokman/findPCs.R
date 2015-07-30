library(pixmap)
numSamples = 500



# Import image files as pixel vectors
# (source: http://conradsanderson.id.au/lfwcrop/)

set.seed(1)
path = "data/faces/"
flist <- sample(list.files(path), numSamples, replace=F)
  # only a subset of images used due to memory limitation!

pix <- matrix(0, numSamples, 4096)
  # each image has 64 by 64 pixels
for (i in 1:numSamples){
  fname <- paste0(path, flist[i])
  pix[i,] <- as.vector(getChannels(read.pnm(fname)))
}



# Find (i) the mean pixel vector and (ii) the PCs of the 
# re-centered pixel vectors responsible for 99% of the
# variations.
# (note: 99% captured by 269 PCs, 95% captured by 121 PCs)

pix_mean <- colMeans(pix)
pix_mean_rep <- matrix(1, numSamples, 1) %*% matrix(pix_mean, nrow=1)
pix_ctr <- pix - pix_mean_rep
pix_eig <- eigen(t(pix_ctr) %*% pix_ctr)

numPCs = min(which(
  cumsum(pix_eig$values) / sum(pix_eig$values) > 0.99
  ))
pix_PCs <- (pix_eig$vectors)[,1:numPCs]



# Save the mean and principal components

df <- data.frame(cbind(pix_mean, pix_PCs))
colnames(df) <- c("mean", paste0("PC", 1:numPCs))
write.csv(df, "PCs.csv", row.names=FALSE)
