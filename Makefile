CSV := $(wildcard *.csv)
PDF:=$(patsubst %.csv, %.pdf, $(CSV))

.PHONY : all
all : pdf

pdf : $(PDF)

%.pdf : %.csv
	./makecards.sh $<
