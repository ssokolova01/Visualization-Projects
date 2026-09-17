# Stage 0 - Technical Writing and First Steps in R #

The opening stage of the HackBio Data Visualization in Bio (vizbio) Internship, covering two outputs: 
* Short technical essay written for both scientific and general audiences;
* Simple R script introducing data structures and string handling.

## **Repository structure** ##
```
.
├── README.md
├── essay/
│   └── HackBio_Viz_Stage_0_Report_Final.md
└── scripts/
    └── team_member_info.R
```

## **Part 1 - Technical Essay** ##
**Title:** *Visualization for Healthcare Translation*

**Working Topic:** Why Clinicians Ignore Your Beautiful Plots (And How to Fix That)

**Brief:** Scientists optimize for analytical depth; clinicians optimize for speed of comprehension. The article discusses that mismatch and reviews design choices that make data visualization usable at the point of care. Dashboards are considered as the bridge between demands of scientific and clinical public.

**Structure:** 

* *Introduction:* Quick historical reference to data visualization (first attempts in the 19th century). Healthcare data visualization purposes: decision-making, pattern recognition, data simplification. Overview of possible accommodation solutions for data visualization in healthcare with dashboards and infographics as examples.
  
* *Scientist Perspective:* Complex visualization decisions (heatmaps, network diagrams, 3D plots) as part of academic standards.
  
* *Clinician Perspective:* Main purpose of visualization are fast decisions and pattern recognition for patient monitoring. Best visualization practice: simple bar charts, line graphs of vital signs and clearly labelled alerts.
  
* *The Gap Between Scientists and Clinicians:* Different visualization purposes: scientifically interesting detail and clinically actionable information. Different accents in professional training: statistical graphics interpretation on one side, clinical pattern recognition on the other. Consequences: misinterpretation and medication errors.
  
* *Conclusions and Solutions:* Collaboration between scientists and clinicians from the initial design stage. Usability prioritized over aesthetics. The five C's of clinical visualization: clarity, context, color, consistency, conciseness. Structural data organization: visual hierarchy and appropriate chart selection. Dashboards are presented as the direction of travel: hierarchical information architecture; high-level metrics and alerts on the overview; detail behind interactive elements; filters for personalized (clinical specialization) information priority. The closing argument: the same visualization work serves two different ends — revealing hidden patterns in research and saving lives in clinical care.

**Skills demonstrated:**

* Writing for a wide audience without losing technical accuracy.
* Structuring an argument: problem, mechanism, proposed solution.
* Translating between two professional vocabularies (research and clinical).
* Referencing in Vancouver style, with nine cited sources spanning peer-reviewed literature, NHS guidance and industry publications.

## **Part 2 - R script: team member information** ##

```
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
```

**Output**
```
[1] "Hi, my name is Svetlana Sokolova, an alumni from Queen's University Belfast. My favorite gene is sim in Drosophila melanogaster."
```

**What the script demonstrates**

**Why a list rather than a vector?**

* An R vector requires all elements to share a single type, and would flatten a set of related fields into an unlabelled sequence.
* A list holds named elements and keeps each field independently addressable, which is the appropriate structure for a record describing one entity.
* Named elements are accessed with `$`, making the code self-documenting: `team_member$affiliation` states what it retrieves.

**Why `paste0()` rather than `paste()`?**

* `paste()` inserts a space separator between arguments by default, which would produce unwanted spaces before punctuation.
* `paste0()` concatenates with no separator, so spacing and punctuation are controlled explicitly inside the string fragments — necessary to get `"sim in Drosophila melanogaster."` rather than `"sim in Drosophila melanogaster ."`.

**About the gene**

`sim` (single-minded) is a transcription factor in Drosophila melanogaster and a master regulator of central nervous system midline cell development.

**Tools**

Base R only. No external packages required.

```
source("scripts/team_member_info.R")
```

*Created as part of the HackBio Data Visualization in Bio (vizbio) Internship (Stage 0).*
