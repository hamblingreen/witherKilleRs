#"WitherKilleRs.R" by hamblingreen

#GLOBAL VARIABLES
#"world" defines which world folder to use. Look at list_worlds to find the world you want to analyze. "x.chunks" and "z.chunks" define the search area.
  world <- "uBFIYHK3JAA="
  x.chunks <- -50:50
  z.chunks <- -50:50
  Rbedrock.loc <- "C:/Users/hambl/Documents/R/Scripts/Rbedrock.R"

#Installing and/or loading Shiny & sourcing "Rbedrock.R" to load rbedrock. Listing worlds.
  if (!require(pacman)) {install.packages("pacman")}
  p_load(shiny)
  source(Rbedrock.loc)
  list_worlds()
#Creating continue window
  ui <- fluidPage(mainPanel("Before continuing, change the global variables in this script! Read the notes above them for more information. Edit those variables, then come back, restart R, and clear the environment variables. Run this script again with these new changes"))
  server <- function(input, output) {}
  shinyApp(ui = ui, server = server)
#Specifying which world to analyze
  db <- bedrockdb(world)
#Creating a table of all possible chunk locations using variables "x.chunks" and "z.chunks"
  x <- x.chunks
  z <- z.chunks
  g <- expand_grid(x=x,z=z)
#Creating a list of blocks at the lowest point in your world, a chunk key, and a block list with only the coordinates, dimension, and block names (to cut down on data size)
  block_list <- get_subchunk_blocks(db, g$x, g$z, 0, 0) %>% compact()
  blocks <- block_list[["@0:0:0:47-0"]]
  block_list <- get_subchunk_blocks(db, g$x, g$z, 0, 0, names_only = TRUE)
#Sorting subchunks by which have the most and which have the least water at bedrock level
  count_water <- function(blocks){
    w <- blocks[,1:5,] == "minecraft:water"
    sum(w)
  }
  water_num <- block_list %>% map_int(count_water)
  pool_chunks <- water_num[water_num > 0] %>% sort() %>% rev()
  pool_chunks
#Printing list as a tibble
  pos <- names(pool_chunks) %>% chunk_pos()
  tbl <- tibble(x = 16*pos[,1], z= 16*pos[,2], size = pool_chunks)
#Final output
  tbl