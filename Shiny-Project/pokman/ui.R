# include other pics (animals, art)


source("helpers.R")


shinyUI(navbarPage(
  
  "PCA & Facial Images",
  inverse=TRUE,

  tabPanel(
    "introduction",
    
    tabsetPanel(
      
      tabPanel(
        "facial images as high-dimensional data",
        
        br(),
        
        fluidRow(

          column(
            5,
            h4("image of one person (grayscale, 64 x 64 pixels)",
               align = "center"),
            p(img(src="sample.jpg", width="50%"), align="center")
            ),
            
          column(
            5,
            h4("a point in 4096-dimensional space",
               align = "center"),
            p(img(src="hidim-single.jpg", width="75%"),
              align="center")
            )
          
        ),
          
        br(), br(),
        
        fluidRow(

          column(1),
          
          column(

            5,
            
            p("A grayscale pixel is represented by a number
              (between 0 and 1), so a grayscale image with 64 by
              64 pixels is represented by a vector of 4096
              numbers, or equivalently a point in 
              a 4096-dimensional space.", align = "justify")
            
            )

          )
        
        ),
      
      
      tabPanel(
        
        "redundancy of dimensions",
        
        br(),
        
        fluidRow(
          
          column(
            5,
            h4("images of all people", align = "center"),
            p(img(src="samples.jpg", width="50%"), align="center")
            ),
          
          column(
            5,
            h4("a lot of points in 4096 dimensions", 
               align = "center"),
            p(img(src="hidim-all.jpg", width="75%"),
              align="center")
            )
          
        ),
        
        br(),
        
        fluidRow(
          
          column(1),
          
          column(
            
            5,
            
            p("Suppose we have images of all people in the world.",
              align = "justify"),
            
            p("That's a lot of points in the 4096-dimensional
              space, but still they can't occupy much of the
              entire space; most points in it correspond
              to nothing like a human face.", align = "justify"),
            
            p("In other words, facial images tend to vary in
              much less than 4096 directions.", align = "justify")
            
          ),
          
          column(1),
          
          column(
            
            5,
            
            p("My actual dataset: 500 images from Labelled Faces 
              in the Wild (cropped and grayscale). For this
              dataset, it turns out 95% of variation is captured
              in 121 directions, and 99% of variation is captured
              in 269 directions.")
            
            )
          
        )
        
      ),
        
      tabPanel(
        
        "reduction of dimensions",
        
        br(),
        
        fluidRow(
          
          h4("projection to a 269-dimensional subspace", 
             align = "center"),
          
          p(img(src="hidim-reduce.jpg", width="30%"),
            align="center")
                    
          ),
        
        br(),
        
        fluidRow(
          
          column(1),
          
          column(
            
            5,
            
            p("The distribution of those points
              can be captured using principal component
              analysis (PCA).", align = "justify"),
            
            p("First, find the center of the points (mean).",
              align = "justify"),
            
            p("Then, find the most prominent directions of
              variation from the center (principal components).",
              align = "justify")

            ),
          
          column(1),
          
          column(
            
            5,
            
            p("For my dataset, the first 269 principal
              components capture 99% of the variation.",
              align = "justify"),
            
            p("Data compression: for a facial image, replacing
              the 4096 pixels by the 269 principal components
              is a much more efficient way to store its data,
              with only a minimal loss of information.",
              align = "justify"),
            
            p("Face detection: for an arbitrary image,
              measuring how much information is retained by
              the 269 principal components provides a (crude)
              way to automatically detect whether it contains 
              a human face.", align = "justify")
            
            )
          
          )
        
        )
      
      )
    
    ),
  
  tabPanel(
    "principal components",
    
    fluidRow(
      
      column(
        
        5,
        
        p("Dataset: 500 images from Labelled Faces in the
           Wild (grayscale, cropped)")
        
        ),
      
      column(
        4,
        selectInput(
          "n.PCs1", "Choose no. of principal components",
          choices = c(8, 18, 32, 50), 
          selected = 8)
        )
      
    ),
      
    hr(),
    
    fluidRow(
      
      column(
        4,
        plotOutput("face.mean"),
        h4("mean image", align = "center")
        ),
        
      column(
        8,
        plotOutput("face.PCs"),
        h4(textOutput("face.PCs.txt"), align = "center")
        )
      
      )
    
    ),
  
  tabPanel(
    "compression & detection",
  
    fluidRow(
      
      column(
        6,
        selectInput("person", "Choose a picture",
                    choices = picList(),
                    selected = "George_W_Bush_0001"
                    )
      ),
      
      column(
        6,
        sliderInput("n.PCs2", "Choose no. of principal components",
                    min = 0, max = 269, value = 0, step = 5,
                    ticks = FALSE)
      )

    ),
    
    hr(),
    
    fluidRow(
      
      column(
        6,
        plotOutput("pic.ori")
        ),
      
      column(
        6,
        plotOutput("pic.cmp"),
        h4(textOutput("score.txt"), align = "center")
        )
      
      )    
    
    )
  
  
))