#!/bin/bash
# filters the ichidan and godan verbs from a tab separated csv file with fields "reading brief", "item", "meaning brief", "item type" AND "part of speech" and saves them as tab separated file that can be processed into flashcards with makecards.sh
# EXAMPLE: ./verbs.sh vocab-1-10.csv verbs-1-10
# OUTPUT: verbs-1-10.csv  (ready for processing with ./makecards.sh verbs-1-10.csv)./verb	

cat $1 | awk -F"\t" ' $0~/godan|ichidan/ ' | awk -F"\t" '{ print $1 "\t" $2 "\t" $3 "\t" $4 }' > $2.csv
