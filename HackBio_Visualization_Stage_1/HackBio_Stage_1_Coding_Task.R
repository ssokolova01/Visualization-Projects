# Task 1
# For the GC% calculation, make it robust enough to handle 
# nucleotide sequences written in upper and lower case. 
# I.e., GCATTTAT and gcaTTTAT should both return 25%.

gene_X <- 'CCATGGGTTTCAAATTCG'
length(gene_X)
gene_X <- strsplit(x = gene_X, split = "")[[1]]
print(gene_X)

gc_counter <- 0 #initialize with zero
for (nc in gene_X) {           #for loop
  #print(nc)
  
  if (nc == 'G'| nc == 'C') {  #if statement
    gc_counter = gc_counter+1 #operation
  }
}

(gc_counter / length(gene_X)) * 100


# Combine it all into function
GC_Calculator <- function(input_gene) {
  input_gene <- toupper(input_gene)  # Convert to uppercase
  input_gene <- strsplit(x=input_gene, split = "")[[1]]
  print(length(input_gene))
  
  # the core operations
  
  gc_counter <- 0 #initialize with zero
  for (nc in input_gene) {           #for loop
    #print(nc)
    
    if (nc == 'G'| nc == 'C') {  #if statement
      gc_counter = gc_counter+1 #operation
    }
  }
  
  return((gc_counter / length(input_gene)) * 100)
  
}

# Testing the code
# All uppercase letters
gene_X <- 'CCATGGGTTTCAAATTCG'
my_final_GC_percent <- GC_Calculator(input_gene = gene_X)
print(my_final_GC_percent)

# All lowercase letters
gene_Y <- 'gcatttat'
my_final_GC_percent <- GC_Calculator(input_gene = gene_Y)
print(my_final_GC_percent)

# Lowercase and uppercase letters in the sequence
gene_Z <- 'gcaTTTAT'
my_final_GC_percent <- GC_Calculator(input_gene = gene_Z)
print(my_final_GC_percent)

#####################################################################
# Alternative way
# Combine it all into FUNCTION
GC_Calculator <- function(input_gene) {
  
  input_gene <- strsplit(x=input_gene, split = "")[[1]]
  print(length(input_gene))
  
  # the core operations
  
  gc_counter <- 0 #initialize with zero
  for (nc in input_gene) {           #for loop
    #print(nc)
    
    if (nc == 'G'| nc == 'C'| nc == 'g' | nc == 'c') {  #if statement
      gc_counter = gc_counter+1 #operation
    }
  }
  
  return((gc_counter / length(input_gene)) * 100)
  
}


# Testing the code
# All uppercase letters
gene_X <- 'CCATGGGTTTCAAATTCG'
my_final_GC_percent <- GC_Calculator(input_gene = gene_X)
print(my_final_GC_percent)

# All lowercase letters
gene_Y <- 'gcatttat'
my_final_GC_percent <- GC_Calculator(input_gene = gene_Y)
print(my_final_GC_percent)

# Lowercase and uppercase letters in the sequence
gene_Z <- 'gcaTTTAT'
my_final_GC_percent <- GC_Calculator(input_gene = gene_Z)
print(my_final_GC_percent)

############################################################################
# AMINO ACID PART
setwd("C:/Users/2759309/Desktop")
# Load the amino acid table
amino_acid_table <- read.csv("Amino_Acid.csv", header = TRUE)

# Create a named vector (name: 1-letter AA; value: weight)
aa_weights <- setNames(amino_acid_table$Weight..Da., 
                       amino_acid_table$X1.Letter.Code)

# Protein weight calculator function
Protein_Weight_Calculator <- function(protein_sequence = "SVETLANA") {
  
# Convert to uppercase to handle case variations
  protein_sequence <- toupper(protein_sequence)
  
# Split the protein sequence into individual amino acids
  amino_acids <- strsplit(protein_sequence, split = "")[[1]]
  
# Initialise total weight
  total_weight_Da <- 0
  
# Valid amino acid letters
  valid_aa <- names(aa_weights)
  
# Loop through each amino acid
  for (aa in amino_acids) {
    
# Check if the amino acid is valid
    if (aa %in% valid_aa) {
# Add the weight to initial total weight
      total_weight_Da <- total_weight_Da + aa_weights[aa]
    } else {
# Return 0 in case the invalid character found
      print(paste("Invalid amino acid found:", aa))
      return(0)
    }
  }
  
# Convert from Daltons to KiloDaltons
  total_weight_kDa <- total_weight_Da / 1000
  
  return(as.numeric(total_weight_kDa))
}

# Test with default (my name: SVETLANA)
print(Protein_Weight_Calculator())

# Test with a valid protein
print(Protein_Weight_Calculator("ACDEFGHIKLMNPQRSTVWY"))

# Test with invalid character (B)
print(Protein_Weight_Calculator("ACBDEFG"))

