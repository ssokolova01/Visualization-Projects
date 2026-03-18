# Creating a list with team member information
team_member <- list(
  name = "Svetlana Sokolova",
  affiliation = "Queen's University Belfast",
  favorite_gene = "sim",
  organism = "Drosophila melanogaster"
)

# Print team member data in form of sentence
print(paste0("Hi, my name is ", team_member$name, 
             ", an alumni from ", team_member$affiliation, 
             ". My favorite gene is ", team_member$favorite_gene, 
             " in ", team_member$organism, "."))