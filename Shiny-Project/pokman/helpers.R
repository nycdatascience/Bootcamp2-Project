library(pixmap)

plot_matrix <- function(pix_matrix){
  plot(pixmapGrey(pix_matrix, cellres=1))
}

picList <- function(){
  return(list(
    "Aung San Suu Kyi" = "Aung_San_Suu_Kyi_0001",
    "Javier Bardem" = "Javier_Bardem_0001",
    "Cate Blanchett" = "Cate_Blanchett_0001",
    "George W. Bush" = "George_W_Bush_0001",
    "Chen Shui-bian" = "Chen_Shui-bian_0001",
    "Hillary Clinton" = "Hillary_Clinton_0001",
    "Daniel Day-Lewis" = "Daniel_Day-Lewis_0001",
    "Catherine Deneuve" = "Catherine_Deneuve_0001",
    "Queen Elizabeth II" = "Queen_Elizabeth_II_0001",
    "Steffi Graf" = "Steffi_Graf_0001",
    "Vaclav Havel" = "Vaclav_Havel_0001",
    "John Malkovich" = "John_Malkovich_0001",
    "Nelson Mandela" = "Nelson_Mandela_0001",
    "Angela Merkel" = "Angela_Merkel_0001",
    "Gregory Peck" = "Gregory_Peck_0001",
    "Vladimir Putin" = "Vladimir_Putin_0001",
    "Aishwarya Rai" = "Aishwarya_Rai_0001",
    "Isabella Rossellini" = "Isabella_Rossellini_0001",
    "Maggie Smith" = "Maggie_Smith_0001",
    "Bruce Springsteen" = "Bruce_Springsteen_0001",
    "Jon Stewart" = "Jon_Stewart_0001",
    "Meryl Streep" = "Meryl_Streep_0001",
    "Andy Warhol" = "Andy_Warhol_0001",
    "Naomi Watts" = "Naomi_Watts_0001",
    "Serena Williams" = "Serena_Williams_0001",
    "Faye Wong" = "Faye_Wong_0001",
    "Zinedine Zidane" = "Zinedine_Zidane_0001",
    "geometric pattern 1" = "00pattern1",
    "geometric pattern 2" = "00pattern2",
    "geometric pattern 3" = "00pattern3",
    "horse" = "00horse",
    "puppy" = "00dog2",
    "gorilla" = "00gorilla",
    "Mona Lisa" = "00MonaLisa",
    "van Gogh" = "00vanGogh",
    "Weeping Woman" = "00Picasso"
    ))
}
