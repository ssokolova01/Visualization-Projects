# Stage 1 - Functions, Loops and Input Validation in R #

Two command-line tools written in base R: a GC content calculator and a protein molecular weight calculator. 
The focus of this stage is writing functions that handle real input robustly (mixed case, invalid characters, sensible defaults) rather than assuming clean data.
--------------------------------------------------------------------------------------------------------------------------------------------

## **The Task** ##

***Stage One: Writing Functions in R***

**Task 1 - GC content**

Make the GC% calculation robust enough to handle nucleotide sequences written in upper and lower case, so that `GCATTTAT` and `gcaTTTAT` both return 25%.

**Task 2 — Protein molecular weight**

Given a reference table of amino acid molecular weights:

* Write a function that returns the molecular weight of any protein in kiloDaltons.
* Let the function accept your name as input by default.
* If the input contains a non-protein character (such as B), return 0 for that value.
* Write an essay describing the step-by-step recipe used to solve the task in R.

Table of amino acid molecular weights:
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
















