#!/bin/bash
# ./rebuild.sh "vocab" "21" "30"
# ./rebuild.sh "kanji" "41" "50"
TYPE=$1
START=$2
END=$3
LEVELS=$(echo $START-$END)




if [ $TYPE = vocab ]; then 
  cp csv/$TYPE-$LEVELS.csv .

 for (( c=$START; c<=$END; c++ ))
 do
	./makecards.sh -l $c $TYPE-$LEVELS.csv
    ./makecards.sh -l $c -p a4 $TYPE-$LEVELS.csv
 done
    ./makecards.sh -o verbs $TYPE-$LEVELS.csv
    ./makecards.sh -o verbs -p a4 $TYPE-$LEVELS.csv
elif [ $TYPE = kanji ]; then
  cp csv/$TYPE-$LEVELS.csv .
 ./makecards.sh $TYPE-$LEVELS.csv
 ./makecards.sh -p a4 $TYPE-$LEVELS.csv
else
  cp csv/$TYPE.csv .
 ./makecards.sh $TYPE.csv
 ./makecards.sh -p a4 $TYPE.csv
fi

rm *.csv



