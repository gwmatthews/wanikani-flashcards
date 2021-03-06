# Wanikani Flashcards 

A LaTeX package and bash script for producing flashcard sets from .csv files generated by Wanikani Item inspector. This repo also has pre-built pdfs of all Wanikani kanji organized in sets of 10 levels, as well as the first 20 levels of vocabulary, one level per file, a collection of all of the godan and ichidan verbs from levels 1-10, plus a set of recent leeches of mine. If you want leech cards for yourself you'll have to build your own ;)

## Features

- Generates pdf files with 15 cards per page on letter paper.
- Works with either lists of kanji, vocabulary, radicals or any combination. 
- Kanji cards print kanji in larger font size so you can distinguish vocabulary from kanji cards of the same character -- readings are usually different after all!
- Kanji readings are written in katakana if first reading in WK is onyomi, and you have a csv with column 5 set to Readings by Type (see below) otherwise hiragana.
- For all readings in hiragana, download csv files with only 4 fields -- see below.
- Radicals are rendered in light gray larger characters. Some non-standard radicals on Wanikani are images, and those will end up with blank card fronts -- you have to draw those yourself :P
- Backs of cards are printed in lighter color which makes less likely that you will see through the card when printed on ordinary paper.
- NEW: backs of cards now have each item's level number in the corner.


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
- Wanikani Item Inspector script installed in your browser, plus a subscription to Wanikani -- this is for getting the csv files. There are some in the repo as well.

### How to use

- Download csv file from Item Inspector with these settings:
  - **Tables tab** > Table list - pick "Leeches" for your leeches, for other sets of flashcards, you can create a new table, such as "Flashcards Kanji" or "Flashcards vocabulary" so you can customize them without messing up the default tables in Item Inspector. Try different settings and seee what you get. The most important thing is which data you export and in which order. Keep reading for details.
  - **Export tab** -- any cell separator and use of quotes should work.
  - **Export tab** > exported columns:
    - column 1: Reading Brief
    - column 2: Item
    - column 3: Meaning Brief
    - coulmn 4: Level
    - column 5: Item Type
    - OPTIONAL column 6: Reading by Type (on kun) OR Part of Speech 
  - **Filters tab:** choose radicals, kanji and/or vocabulary as you like, filter as you like by level (including ranges like 12-18), SRS stage or whatever. (Radicals that are on WK as images remain blank on the front of the card, but the backs still have meanings, you can draw these radicals on the front and these cards won't mess things up otherwise.)

- **Usage examples**
  - `./makecards.sh myfile.csv` produces flashcards of all contents of the csv file. If you want kanji cards with katakana for on readings, you need column 5 set to Reading by Type (on kun). If this column is left blank all readings are printed in hiragana.
  - `./makecards.sh -p a4 myfile.csv` prints your cards on a4 paper size as `myfile-a4.pdf`.
  - `./makecards.sh -o verbs myfile.csv` prints cards of only godan and ichidan verbs, provided that you have column 5 set to Part of Speech, as `myfile-verbs.pdf`.
  - `./makecards.sh -o adjectives -p a4 myfile.csv` prints all adjectives from your file as `myfile-adjectives-a4.pdf` on a4 paper. You can also get only nouns with `-o nouns` -- you can't get BOTH nouns and adjectives though. One set at a time.
  - Lately I have been experimenting with filtering by level number and that is possible within certain constraints. It is possible to start with a file called something like `vocab-1-25.csv` and then run `./makecards.sh -l 18 vocab-1-25.csv` to get only level 18 cards. This is likely of limited use, but was added to help me build individual level sets more easily out of larger csv files. 

## Bug reports and contributions

- Please let me know, here or on WK forum, if you run into any problems!
- Also feel free to contribute your own build script for other operating systems.
