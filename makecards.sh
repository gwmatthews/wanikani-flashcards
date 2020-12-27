#!/bin/bash

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

usage() {

    echo Basic use "$0 <filename>"
    echo For a4 paper "$0 -p a4 <filename>"
    echo For only verbs "$0 -o verbs <filename>"
    echo For only nouns "$0 -o nouns <filename>"
    echo For only adjectives "$0 -o adjectives <filename>"
    echo part of speech can be combined with papersize "$0 -o verbs -p a4 <filename>" 
    echo "$0 -h -? or --help" print this message.
}


if [ $# -lt 1 ]; then
	    usage
	  	exit 1 # error
fi

# Declare variables
FILENAME=
PAPER=
ONLY=

while :; do
    case $1 in
        -h|-\?|--help)
            usage    # Display a usage synopsis.
            exit
            ;;
        -p)
            if [ "$2" ]; then
                PAPER=$2
                shift
            else
                die 'ERROR: "-p" requires a paper size, try a4 or letter.'
            fi
            ;;
         -o)
            if [ "$2" ]; then
                ONLY=$2
                shift
            else
                die 'ERROR: "-o" requires a part of speech, try verbs.'
            fi
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            die 'ERROR: Unknown option.'
            ;;
        *)               # Default case: No more options, so break out of the loop.
            break
    esac

    shift
done

# Assigned here to enable optional flag cases to work.

FILENAME=$1
SET="${FILENAME%.[^.]*}"

# Use options if found, otherwise set default values.

if [ "$PAPER" ]; then
    echo "$PAPER"
else
    PAPER=letter
fi

if [ "$ONLY" ]; then
    SET="${FILENAME%.[^.]*}-$ONLY"
else
    ONLY=all
    SET="${FILENAME%.[^.]*}"
fi

## set paper size

if [ $PAPER = a4 ]; then
 sed -i -e 's/letterpaper/a4paper/' templates/cards
 sed -i -e 's/letterpaper/a4paper/' templates/remix
else
 sed -i -e 's/a4paper/letterpaper/' templates/cards
 sed -i -e 's/a4paper/letterpaper/' templates/remix
fi

## filter by part of speech

if [ $ONLY = verbs ]; then
 cat $FILENAME | awk -F"\t" ' $0~/godan|ichidan/ ' | awk -F"\t" '{ print $1 "\t" $2 "\t" $3 "\t" $4 }' > $SET.csv
elif [ $ONLY = nouns ]; then
 cat $FILENAME | awk -F"\t" ' $0~/noun/ ' | awk -F"\t" '{ print $1 "\t" $2 "\t" $3 "\t" $4 }' > $SET.csv
elif [ $ONLY = adjectives ]; then
 cat $FILENAME | awk -F"\t" ' $0~/adjective/ ' | awk -F"\t" '{ print $1 "\t" $2 "\t" $3 "\t" $4 }' > $SET.csv
fi

## get LaTeX wrappers from card-frame file

BEGINFRONT=$(sed -n '2,4 p' < templates/card-frame)
BEGINBACK=$(sed -n '5,8 p' < templates/card-frame)
END=$(sed -n '9,11 p' < templates/card-frame)


### WHAT DOES THE TANGLE OF CODE BELOW DO?

# sed -e 's_,_\t_g'                                              # replace commas with tabs
# -e 's_;_\t_g'                                                  # replace semicolons with tabs
# -e 's_"__g'                                                    # delete quotation marks
# awk -F"\t" '{ print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 }'      # print up to 5 fields (reading, item, meaning, type, first of on/kun readings); if only 4 fields, all readings will be hiragana
# sed -f templates/kana.sed                                           # check if first reading is onyomi -- if it is, replace hiragna with katakana
# awk -F"\t" '{ print "{" $1 "}{" $2 "}{" $3 "}{" $4 "}" }'      # print first four fields wrapped in curly braces
# sed -e 's_{radical}_{r}_'                                      # replace "radical" item type with "r" (handled by flashcards.sty)
# -e 's_{Unavailable}_{radical}_'                                # replace "Unavailable" in reading field with radical
# -e 's_{vocabulary}_{}_'                                        # remove "vocabulary" item type with empty field (for defaault format)
# -e 's_{kanji}_{k}_'                                            # replace "kanji" with "k" (handled by flashcards.sty)
# -e 's_}{[a-z]*}{_}{}{_'                                        # remove any written descriptions of radicals
# -e 's_咅__'                                                    # remove placeholder for radical images
# -e 's/{/\\flashFront{/'                                        # FRONT ONLY add front LaTeX code
# -e 's/{/\\flashBack{/'                                         # BACK ONLY add back LaTeX code
# sed -f templates/spacing.sed                                   # divide up file into 15 line chunks with LaTeX in between chunks
# sed '/3/ a\\\RLmulticolcolumns'                                # FRONT ONLY add LaTeX for Right to Left columns
# sed '/3/ a\\\LRmulticolcolumns'                                # BACK ONLY add LaTeX for Left to Right columns


## build front and back of cards

FRONT=$(cat $SET.csv | sed -e 's_,_\t_g'  -e 's_;_\t_g' -e 's_"__g' | awk -F"\t" '{ print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 }' | sed -f templates/kana.sed | awk -F"\t" '{ print "{" $1 "}{" $2 "}{" $3 "}{" $4 "}" }' | sed -e 's_{radical}_{r}_' -e 's_{Unavailable}_{radical}_' -e 's_{vocabulary}_{}_' -e 's_{kanji}_{k}_' -e 's_}{[a-z]*}{_}{}{_' -e 's_咅__'  -e 's/{/\\flashFront{/' |  sed -f templates/spacing.sed | sed '/3/ a\\\RLmulticolcolumns')

BACK=$(cat $SET.csv | sed -e 's_,_\t_g'  -e 's_;_\t_g' -e 's_"__g' | awk -F"\t" '{ print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 }' | sed -f templates/kana.sed | awk -F"\t" '{ print "{" $1 "}{" $2 "}{" $3 "}{" $4 "}" }' | sed -e 's_{radical}_{r}_' -e 's_{Unavailable}_{radical}_' -e 's_{vocabulary}_{}_' -e 's_{kanji}_{k}_' -e 's_}{[a-z]*}{_}{}{_' -e 's_咅__'  -e 's/{/\\flashBack{/' |  sed -f templates/spacing.sed | sed '/3/ a\\\LRmulticolcolumns')

## add front and back of card LaTeX wrappers

echo "$BEGINFRONT" "$FRONT" "$END" > $SET-cards-front.tex
echo "$BEGINBACK" "$BACK" "$END"  > $SET-cards-back.tex

## duplicate the cards template

cp templates/cards $SET-cards.tex

## create temp pdf sheets to be reshuffled and rebuilt in code that follows

xelatex $SET-cards.tex

## reshuffle pages for two sided printing

## initialize variables

PAGES=$(pdfinfo $SET-cards.pdf | grep "Pages" | awk '{print $NF}')    
REVERSE=$(( PAGES / 2 ))
OUTPUT=pagelist.tex
NUM=0

## copy the template

if [ $PAPER = a4 ]; then
    cp templates/remix $SET-a4.tex
else
    cp templates/remix $SET.tex
fi                                               

## construct the pagelist array

arr=()                                                                
for ((i=1; i<=$REVERSE; i++)); do
    NUM=$i
	arr+=( "$NUM" )
    NUM=$(( REVERSE + i))
    arr+=( "$NUM" )
done

##### format for pdfpages

PAGELIST=$(echo ${arr[@]} | sed 's/\s/, /g')                          

## assemble full line of LaTeX code

REORDERED="\includepdf[pages={${PAGELIST}}, delta=0 0, offset=0 0]{$SET-cards.pdf}"   

## export as pagelist.tex

echo $REORDERED > $OUTPUT                                             

## compile reordered flashcard pages

if [ $PAPER = a4 ]; then
    xelatex $SET-a4.tex
else
    xelatex $SET.tex
fi                                                

## clean up the mess

rm ./*.aux
rm ./*.log
rm ./*.out
rm ./*.tex
rm ./*-cards.pdf


