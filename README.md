# Wanikani Flashcards

A LaTeX package and bash script for producing flashcard sets from .csv files generated by Wanikani Item inspector. This repo also has pre-built pdfs of all Wanikani kanji organized in sets of 10 levels, as well as the first 20 levels of vocabulary, one level per file, plus a set of recent leeches of mine. If you want leech cards for yourself you'll have to build your own ;)

## Features

- Generates pdf files with 15 cards per page on letter paper.
- Works with either lists of kanji, vocabulary, radicals or any combination. 
- Kanji cards print kanji in larger font size so you can distinguish vocabulary from kanji cards of the same character -- readings are usually different after all!
- Kanji readings are written in katakana if first reading in WK is onyomi, otherwaise hiragana.
- For all readings in hiragana, download csv files with only 4 fields -- see below.
- Radicals are rendered in light gray larger characters. Some non-standard radicals on Wanikani are images, and those will end up with blank card fronts -- you have to draw those yourself :P
- Backs of cards are printed in lighter color which makes less likely that you will see through the card when printed on ordinary paper.
- NEW: added verbs.sh script to print only verbs -- requires exported column 5 to be "part of speech"

## Requirements

- LaTeX packages:
  - xeCJK
  - ctexhook
  - nopageno
  - multicol
  - anyfontsize
  - hyperref
  - tcolorbox
  - etoolbox
  - pdfpages
- xelatex
- standard Linux utilities such as sed, awk, grep
- .csv files downloaded from Wanikani Item Insepector with the following settings
	- tables > export > exported column 1 > reading brief
	- tables > export > exported column 2 > item
	- tables > export > exported column 3 > meaning brief
	- tables > export > exported column 4 > item type
    - (OPTIONAL) tables > export > exported column 5 > reading by type on, kun -- if this is omitted, all readings will be rendered in hiragana
    - (OPTIONAL) tables > export > exported column 5 > part of speech -- before running ./makecards.sh run verbs.sh like so: `./verbs.sh myfile.csv verbs` this will output `verbs.pdf`

- NOTE: will now also work with tab, or semicolon separated cells, as well as with tables > export > use of quotes > always

## How to use

- Copy .csv files to wanikani-flashcards directory and then run `./makecards.sh filename.csv`
- For a4 paper run `./makecards.sh -p a4 filename.csv`
- The following opitons require vocabulary items and Part of Speech as column 5:
  - `./makecards.sh -o verbs filename.csv` prints only the ichidan and godan verbs
  - `./makecards.sh -o nouns filename.csv` prints only the nouns
  - `./makecards.sh -o adjectives filename.csv` prints only the adjectives

## Bug reports and contributions

- Please let me know, here or on WK forum, if you run into any problems!
- Also feel free to contribute your own build script for other operating systems.
