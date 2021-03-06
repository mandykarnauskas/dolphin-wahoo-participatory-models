# dolphin-wahoo participatory models
## M. Karnauskas

> code for organizing, processing, and analyzing conceptual models from SAFMC dolphin-wahoo workshops

**processConceptualModels.r is step-wise code for organization**

1. Step 1. Put conceptual model into Mental Modeler and export as .csv
    + workshopLocation.mmp is Mental Modeler input file (generated by hand from raw workshop outputs)
    + CHANGE_LOG describes any changes that were made during input to Mental Modeler 
    + workshopLocation_mm.png is picture of clean mental model
    + workshopLocation_matrix.csv is Mental Modeler output in matrix form

2. Step 2. Read file into R and sort matrix into list of relationships
    + workshopLocation_relationships.csv is matrix relationships in list form

3. Step 3. Fill out description column of the relationships_edited.csv
    +  check conceptual models and update any linkages necessary
    + workshopLocation_relationships_edited.csv is matrix relationships in list form with comments 

4. Step 4. Merge edited mental models with relationships_edited.csv
    + workshopLocation_relationships_edited.csv is updated with new linkages

5. Step 5. Create list of terms
    + all_terms.csv is full list of terms across workshops

6. Step 6. Standardize list of terms
    + all_terms_edited.csv is manually edited term list

7. Step 7. Update relationship flat file with new terminology
    + workshopLocation_relationships_newterm.csv is relationship file with new terms

8. Step 8. Specify positive and negaitve relationships
    + workshopLocation_relationships_newterm_scored.csv is relationship file with +/- scores

9. Step 9. Convert back to matrix format
    + workshopLocation_matrix_newterms.csv is matrix form with clean terminology and scored relationships
    + input this back into Mental Modeler or continue analysis





