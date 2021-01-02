#!/bin/bash

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

usage() {

    echo Basic use "$0 <filename>"
    echo For a4 paper "$0 -p a4 <filename>"
    echo For particular level "$0 -l 32 <filename>" Maybe buggy with file names different than the ones I used. Needs work, in other words.
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
LEVEL=

while :; do
    case $1 in
        -h|-\?|--help)
            usage    # Display a usage synopsis.
            exit
            ;;
        -l)
            if [ "$2" ]; then
                LEVEL=$2
                shift
            else
                die 'ERROR: "-p" requires a paper size, try a4 or letter.'
            fi
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

## create new input file renamed according to level

if [ $LEVEL ]; then
 FILTERED=$(echo $FILENAME | sed "s/-.*/-$LEVEL.csv/")
# cat $FILENAME | sed -n "/$LEVEL/p" > $FILTERED
 cat $FILENAME | awk -F"\t" -v a="$LEVEL" '$4==a' > $FILTERED 

 FILENAME=$FILTERED
fi

## Exit if input file is empty

if [ ! -s $FILTERED ]; then
 die 'Nothing to print! Please check your input file or use different options.'
fi

## Get basename of file

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

# define text processing steps
# replace commas and semicolons with tabs, delete quotes

parse() {
 sed -e 's_,_\t_g'  -e 's_;_\t_g' -e 's_"__g'
}

# print up to 6 fields (reading, item, meaning, type, on/kun reading or part of speech)

getfields() {                                                    
 awk -F"\t" '{ print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5 "\t" $6 }'      
}

# check if first reading is onyomi -- if it is, replace hiragna with katakana

katakana() {
 sed -f templates/kana.sed
}

# print first four fields wrapped in curly braces

addbraces() {
 awk -F"\t" '{ print "{" $1 "}{" $2 "}{" $3 "}{" $4 "}{" $5 "}" }'
}

# process item types 
## flag radical items for later reformatting
## remove "Unavailable" from reading
## remove written descriptions of radicals
## remove placeholder for radical images
## remove vocabulary type (for default formatting)
## add flag for kanji type

itemtypes() {
 sed -e 's_{radical}_{r}_' -e 's_{Unavailable}_{radical}_' -e 's_咅__' -e 's_}{[a-z]*}{_}{}{_'  -e 's_{vocabulary}_{}_' -e 's_{kanji}_{k}_'
}

# add LaTeX command for front of cards -e 's_咅_ _'

front() {
 sed -e 's/{/\\flashFront{/'
}

# add LaTeX command for back of cards

back() {
sed -e 's/{/\\flashBack{/'
}

# divide up file into 15 line chunks with LaTeX in between chunks

splitfile() {
 sed -f templates/spacing.sed
}

# add LaTeX to set column order of front to right to left

frontcols() {
 sed '/3/ a\\\RLmulticolcolumns'
}

# add LaTeX to set column order of back to left to right

backcols() {
 sed '/3/ a\\\LRmulticolcolumns'
}

## build front and back of cards

FRONT=$(cat $SET.csv | parse | getfields | addbraces | itemtypes | front | splitfile | frontcols )

BACK=$(cat $SET.csv | parse | getfields | katakana | addbraces | itemtypes | back | splitfile | backcols )

## make sure content is not empty
if [ ! $FRONT ]; then
 die "Nothing to print! No $ONLY found."
fi 

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
#rm ./*-adjectives.csv
#rm ./*-nouns.csv
#rm ./*-verbs.csv

mv *.pdf ..

