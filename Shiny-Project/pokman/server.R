library(pixmap)
source("helpers.R")



pix.PCs <- as.matrix(read.csv("PCs.csv"))
    # first column: mean pixel vectors
    # other columns: principal components of pixel vectors
pix.mean <- pix.PCs[,1]
pix.PCs <- pix.PCs[,-1]



shinyServer(function(input, output) {

  output$face.mean <- renderPlot({
    plot_matrix(matrix(pix.mean, 64, 64))
  })
  
  output$face.PCs <- renderPlot({
    n <- round(sqrt(as.numeric(input$n.PCs1) / 2))
    pix.mat <- matrix(0, n*64, n*128)
    for (i in 1:n){
      for (j in 1:(n*2)){
        pix.mat[((i-1)*64+1):(i*64), ((j-1)*64+1):(j*64)] =
          matrix(pix.PCs[,(i-1)*n*2+j], 64, 64)
      }
    }
    plot_matrix(pix.mat)
  })
  
  output$face.PCs.txt <- renderText({
    paste0("first ", input$n.PCs1, " principal components")
  })
  
  output$pic.ori <- renderPlot({
    dir = "data/faces/"
    path = paste0(dir, input$person, ".pgm")
    plot(read.pnm(path))
  })
  
  output$pic.cmp <- renderPlot({
    dir = "data/faces_cmp/"
    path = paste0(dir, input$person, ".csv")
    coef <- as.matrix(read.csv(path))
    n.PCs <- as.numeric(input$n.PCs2)
    pix.cmp <- pix.mean + 
      as.matrix(pix.PCs[,1:n.PCs]) %*% coef[1:n.PCs]
    plot_matrix(matrix(pix.cmp, 64, 64))
  })
  
  output$score.txt <- renderText({
    if (as.numeric(input$n.PCs2) == 269) {
      path = paste0("data/faces/", input$person, ".pgm")
      pix <- as.vector(getChannels(read.pnm(path)))
      path = paste0("data/faces_cmp/", input$person, ".csv")
      coef <- as.matrix(read.csv(path))
      score <- round(sqrt(sum(coef^2) / sum((pix-pix.mean)^2)), 3)
      paste0("information retained: ", as.character(score*100), "%")
      
    } else {
      ""
    }
  })

  
})