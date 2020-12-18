#!/bin/bash
###  generates Japanese flashcards from csv files produced by Wanikani Item Inspector
###  

function usage {

echo "$0 <filename> (optional, for a4 paper size) a4" 

}

if [ $# -lt 1 ]; then
	    usage
	  	exit 1 # error
fi

FILENAME=$1
SET="${FILENAME%.[^.]*}" 
PAPER=${2:-letter}

## set paper size

if [ $PAPER = a4 ]; then
 sed -i -e 's/letterpaper/a4paper/' templates/cards
 sed -i -e 's/letterpaper/a4paper/' templates/remix
else
 sed -i -e 's/a4paper/letterpaper/' templates/cards
 sed -i -e 's/a4paper/letterpaper/' templates/remix
fi

## get LaTeX wrappers from card-frame file

BEGINFRONT=$(sed -n '2,4 p' < templates/card-frame)
BEGINBACK=$(sed -n '5,8 p' < templates/card-frame)
END=$(sed -n '9,11 p' < templates/card-frame)

## fill content into front of card: wrap comma separated fields in braces, add prefix, divide into sections, same for back


FRONT=$(cat $SET.csv | sed -e 's_^_{_' -e 's_\t_}{_g' -e 's_$_}_' -e 's_"__g' -e 's_,_}{_g' -e 's_;_}{_g' -e 's_{radical}_{r}_' -e 's_{Unavailable}_{radical}_' -e 's_{vocabulary}_{}_' -e 's_{kanji}_{k}_' -e 's_}{[a-z]*}{_}{}{_' -e 's_咅__' | sed 's/{/\\flashFront{/' | sed -f templates/spacing.sed | sed '/3/ a\\\RLmulticolcolumns')

BACK=$(cat $SET.csv | sed -f templates/kana.sed | sed -e 's_^_{_' -e 's_\t_}{_g' -e 's_$_}_' -e 's_"__g' -e 's_,_}{_g' -e 's_;_}{_g' -e 's_{radical}_{r}_' -e 's_{Unavailable}_{radical}_' -e 's_{vocabulary}_{}_' -e 's_{kanji}_{k}_' -e 's_}{[a-z]*}{_}{}{_' -e 's_咅__' | sed 's/{/\\flashBack{/' | sed -f templates/spacing.sed | sed '/3/ a\\\LRmulticolcolumns')

# COMMENT OUT THE PREVIOUS LINE AND UNCOMMENT THE FOLLOWING TO CHANGE KANJI READINGS TO HIRAGANA

#BACK=$(cat $SET.csv | sed -e 's_^_{_' -e 's_\t_}{_g' -e 's_$_}_' -e 's_"__g' -e 's_,_}{_g' -e 's_;_}{_g' -e 's_{radical}_{r}_' -e 's_{Unavailable}_{radical}_' -e 's_{vocabulary}_{}_' -e 's_{kanji}_{k}_' -e 's_}{[a-z]*}{_}{}{_' -e 's_咅__' | sed 's/{/\\flashBack{/' | sed -f templates/spacing.sed | sed '/3/ a\\\LRmulticolcolumns')


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
rm *.tex
rm *-cards.pdf


