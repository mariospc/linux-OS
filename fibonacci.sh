#!/bin/bash


#Σε περίπτωση που ο χρήστης θέλει έναν μόνο αριθμό της συνάρτησης παίρνουμε σαν έξοδο τον αριθμό 1.
if [ $# -eq 1 ]
then
	Num=$1
else
	read -p "How many numbers of the sequence would you like? " Num

fi

#οι πρώτοι δύο αριθμοί fibonacci είναι το 0 και το 1
f1=0
f2=1

echo "The fibonacci sequence for the number $Num is :"


#κάθε επόμενος αριθμός είναι το άθροισμα των δύο προηγούμενων
for (( i=0;i<Num;i++))
do
	echo -n "$f1 "
	fn=$((f1+f2))
	f1=$f2
	f2=$fn
done
