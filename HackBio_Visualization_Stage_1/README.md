# Stage 1 - Functions, Loops and Input Validation in R #

Two command-line tools written in base R: a GC content calculator and a protein molecular weight calculator. 
The focus of this stage is writing functions that handle real input robustly (mixed case, invalid characters, sensible defaults) rather than assuming clean data.
--------------------------------------------------------------------------------------------------------------------------------------------

## **The Task** ##

***Stage One: Writing Functions in R***

**Task 1 - GC content**

Make the GC% calculation robust enough to handle nucleotide sequences written in upper and lower case, so that `GCATTTAT` and `gcaTTTAT` both return 25%.

**Task 2 - Protein molecular weight**

Given a reference table of amino acid molecular weights:

* Write a function that returns the molecular weight of any protein in kiloDaltons.
* Let the function accept your name as input by default.
* If the input contains a non-protein character (such as B), return 0 for that value.
* Write an essay describing the step-by-step recipe used to solve the task in R.

*Table of amino acid molecular weights:*
| Amino Acid | 3-Letter Code | 1-Letter Code | Weight (Da) |
|------------|---------------|---------------|-------------|
| Alanine | Ala | A | 89.09 |
| Arginine | Arg | R | 174.20 |
| Asparagine | Asn | N | 132.12 |
| Aspartic Acid | Asp | D | 133.10 |
| Cysteine | Cys | C | 121.15 |
| Glutamic Acid | Glu | E | 147.13 |
| Glutamine | Gln | Q | 146.15 |
| Glycine | Gly | G | 75.07 |
| Histidine | His | H | 155.16 |
| Isoleucine | Ile | I | 131.18 |
| Leucine | Leu | L | 131.18 |
| Lysine | Lys | K | 146.19 |
| Methionine | Met | M | 149.21 |
| Phenylalanine | Phe | F | 165.19 |
| Proline | Pro | P | 115.13 |
| Serine | Ser | S | 	105.09 |
| Threonine | Thr | T | 119.12 |
| Tryptophan | Trp | W | 204.23 |
| Tyrosine | Tyr | Y | 181.19 |
| Valine | Val | V | 117.15 |

---------------------------------------------------------------------------------------------------------

## **Repository Structure** ##
```
.
├── README.md
├── essay/
│   └── HackBio_Viz_Stage_1_Essay_AminoAcid.md
└── scripts/
    └── HackBio_Viz_Stage_1_Coding_Task.R
```

## **Task 1 - GC content calculator** ##

Calculates the percentage of G and C bases in a nucleotide sequence, accepting upper case, lower case or mixed input.

```
GC_Calculator("CCATGGGTTTCAAATTCG")   # 50
GC_Calculator("gcatttat")             # 25
GC_Calculator("gcaTTTAT")             # 25
```
**How it works**

1. `toupper()` standardizes the input so case never reaches the comparison logic (everything has already been converted to capitals).
2. `strsplit(x, split = "")[[1]]` breaks the string into a vector of single characters.
3. A `for` loop walks the vector, incrementing a counter on each `G` or `C`.
4. The counter is divided by sequence length and multiplied by 100.

**Two approaches to case handling**

The script contains both, deliberately:
| Approach | Condition |
|------------|---------------|
| Standardize the input | `toupper()` first, then test `nc == 'G' | nc == 'C'` |
| Extend the condition | test `nc == 'G' | nc == 'C' | nc == 'g' | nc == 'c'` |

Both return the same answers, but they scale differently. 

Standardizing the input keeps the comparison at two cases no matter what arrives; extending the condition doubles the number of comparisons, and would keep doubling if further variants ever needed handling. 

Normalizing input at the boundary of a function, rather than accounting for every variant inside it, is the more general habit.

**Why `strsplit()` is necessary**

`length()` on a character string returns `1`, not the number of characters (R sees one element, not eighteen). 

Splitting the string into a vector of single characters is what makes both the loop and the length calculation possible. 


## **Task 2 - Protein molecular weight calculator** ##

Calculates the molecular weight of a protein from its one-letter amino acid sequence, returning the result in kiloDaltons.

```
Protein_Weight_Calculator()                        # defaults to "SVETLANA"
Protein_Weight_Calculator("ACDEFGHIKLMNPQRSTVWY")  # all 20 standard amino acids
Protein_Weight_Calculator("ACBDEFG")               # invalid character → message + 0
```
**Reference data**

`Amino_Acid.csv` holds the amino acid name, three-letter code, one-letter code and molecular weight in Daltons for the 20 standard amino acids. Protein sequences are conventionally written in one-letter code, so the calculator needs a way to map each letter to its weight. That mapping is built with `setNames()`, producing a named vector where the letters are names and the weights are values. So `aa_weights["A"]` retrieves a weight directly, with no searching through a data frame row by row.

Note that `read.csv()` transformes the header names: `1-Letter Code` becomes `X1.Letter.Code` and `Weight (Da)` becomes `Weight..Da.`, since R identifiers cannot begin with a digit or contain spaces and parentheses.

**Input validation**

Only 20 letters are valid amino acid codes. Characters such as B, J, O, U, X and Z are not. Each character is tested against the names of the reference vector with `%in%`; on an invalid character the function reports which one it found and returns 0, as the brief requires, rather than silently producing a weight computed from an incomplete sequence. Zero is safe as a sentinel here because no real protein has zero mass, so the value cannot be mistaken for a legitimate result.

**Full walkthrough**

The reasoning behind each design decision (data structure choice, default arguments, standardization, validation, accumulation and unit conversion) is written up step by step in the accompanying essay:

**[Step-by-Step Recipe for Building the Protein Weight Calculator in R](Stage_1_Essay_AminoAcid.md)**

## **Skills demonstrated** ##

* Writing reusable functions with default arguments.
* Iteration with `for` loops and conditional logic.
* Choosing an appropriate data structure: named vectors for direct lookup rather than data frame search.
* Defensive input handling: case standardization and validation against a known set.
* Unit conversion and returning results in the form the field expects (kDa, not Da).
* Testing across representative cases: default, complete valid input and invalid input.

## **Tools** ##

Base R only. No external packages required.

```
source("HackBio_Stage_1_Coding_Task.R")
```

*Created as part of the HackBio Data Visualization in Bio (vizbio) Internship (Stage 1).*

