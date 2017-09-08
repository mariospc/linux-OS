#!/bin/bash
#Γιαννης Πιερρος αεμ 2402
#Καλλιοπη Μαλερου αεμ 2370
#Χριστινα Γονιανακη αεμ 2346
#Μαριος Χιρτογλου αεμ 2426

#Ορίζουμε έναν πίνακα στον οποίο θα καταχωρήσουμε τα Pids
declare pid[50];

#Ορίζουμε τη μεταβλητή count η οποία παίρνει την τιμή του αριθμού των διεργασιών που αφορούν τον Chromium
count=0;

#Συνάρτηση mypid, η οποία καταχωρεί στον πίνακα pid[] τα pid του Chromium, φροντίζοντας να μη λάβουμε υπόψη το ghost pid

mypid(){
count=`ps aux | grep chromium-browser | wc -l`
i=1;
pos=1;
count=$((count - 1));
while [ $i -le $count ] 
do 
#Η μεταβλητή pos αναφέρεται στη θέση του πίνακα των pid
#Από όλες τις διεργασίες, συλλέγουμε αυτές που αναφέρονται στον chromium browser και αφού τις έχουμε ταξινομήσει ανάλογα με τον χρόνο εκκίνησης τους, παίρνουμε το pid τους.
#Η μεταβλητή i αναφέρεται στη γραμμή για αυτό και σε κάθε επανάληψη αυξάνεται κατά 1, ενώ η στήλη που περιέχει τον αριθμό του pid είναι η 2, για αυτο και κρατάμε το 2ο στοιχείο
pid[ $pos ]=`ps -ef --sort=start_time | grep chromium-browser | awk -vi="$i" 'FNR == i {print $2}'` 
i=$(($i + 1));
pos=$(($pos + 1));
done

}

stats(){
#Καλούμε τη συνάρτηση mypid για την καταχώρηση των pid στον πίνακα
mypid
#Ορίζουμε τη μεταβλητή time, η οποία χρησιμοποιείται για τη χρονική στιγμή της καταγραφής
time=0;
#Η συνάρτηση stats τερματίζει όταν δεν υπάρχει άλλη διεργασία στον Chromiun browser
while [ $count -gt 0 ];
do
#Καλούμε ξανά την mypid για να ενημερωθούν τα pid
mypid
#Το πλήθος των διεργασίων που ανήκουν στον Chromium είναι ουσιαστικά το count
#Εφ'όσον ζητάμε άθροισμα για την συνολική κατανάλωση μνήμης σε MB, ορίζουμε μια μεταβλητή αθροιστή
sumRSS=0;
#Αναζητούμε στον ανανεωμένο πίνακα των pid, που πήραμε από την κλήση της συνάρτησης mypid
i=1;
while [ $i -le $count ]; 
do

#Η μεταβλητή currentpid παίρνει την τιμή του τρέχοντος pid σε κάθε επανάληψη
#Για την εύρεση των στατιστικών του κάθε pid, χρησιμοποιείται το αρχέιο status, και ανακατευθύνουμε τυχόντα errors

currentpid=${pid[ $i ]}
file="/proc/$currentpid/status" 2>>errors.txt
echo $currentpid

#Ελέγχουμε αν υπάρχει το αρχείο και θέτουμε στη μεταβλητή RSS την αντίστοιχη τιμή που βρίσκεται στη γραμμή 17
if [ -f $file ];
	then 
	RSS=$(cat /proc/$currentpid/status | awk 'FNR == 17 {print $2}') 2>>errors.txt
	#Ελέγχουμε αν η μεταβλητή πήρε τιμή
	if [ -z "$RSS" ]; then
		continue;	
	fi
	#Υπολογίζουμε το άθροισμα της κατανάλωσης μνήμης
	currentpid=${pid[ $i ]}
	sumRSS=$(($sumRSS + $RSS)) 2>>errors.txt
	i=$(($i + 1))
else #Στην περίπτωση που το αρχείο για το τρέχον pid δεν υπάρχει, προχωρούμε στο επόμενο pid
  	i=$(($i + 1))
    	continue;
fi
done

#Συνολική κατανάλωση μνήμης όλων των διεργασιών σε MB 
sumRSSMB=$(echo "scale=2; $sumRSS / 1024" | bc -l) 2>>errors.txt

#Καταγραφή όλων των στατιστικών στη μεταβλητή results
results="$time $count $sumRSSMB"


#Έλεγχος για την εγγραφή μη μηδενικών δεδομένων στο αρχείο  
if [ $count == 0 ] ||[ $count == 1 ]; 
	then
		continue;
else
#Καταγραφή του περιεχομένου της μεταβλητής results ( των στατιστικών δηλαδή ) στο αρχείο statistics.txt
echo "$results" >> "statistics.txt"
fi;
#Αναμονή 0.5 δευτερόλεπτου
sleep 0.5
#Ανανέωση της χρονικής στιγμής της καταγραφής
time=$(echo "0.5 + $time" | bc) 2>>errors.txt
done
}

#******************************************************************************************


#Η εντολή grep 'chromium' θα επιστρέψει και τον εαυτό της.
#Η εντολή grep [c]hromium ψάχνει για οποιοδήποτε χαρακτήρα της κλάσης [c]
#που το ακολουθάει το hromium.
#To 2o όρισμα είναι τα PID.

while ps aux | grep -q '[c]hromium'
do
kill $(ps aux | grep '[c]hromium' | awk '{print $2}')
done


#εκκινηση μιας απλης διεργασιας του chromium
chromium-browser &
sleep 2
ignore_pids="$(ps aux | grep '[c]hromium' | awk '{print $2}')"

#echo "ignore pids"
#echo ${ignore_pids[*]} 


urls_content=(`cat "url.in"`)
#Αναγνωριση της λιστας με τα urls απο το αρχειο url.in και 
#διαδοχικο ανοιγμα των με αναμονη 10 δευτερολεπτων
for url in "${urls_content[@]}"
	do
		echo "Opening url: $url"
		chromium-browser $url &
		echo "Waiting for the next link...";
		sleep 10;
	done

#Καλουμε την συναρτηση "stats" στο background
stats &

#Αναμονη 30 δευτερολεπτα(resting time)
sleep 30


all_pids="$(ps aux | grep '[c]hromium' | awk '{print $2}')"
#echo "all_pids"
#echo ${all_pids[*]}

declare usefull_pids;
index=0;

for pid in ${all_pids}; do
  flag=0
  for pid2 in ${ignore_pids}; do
    if [ $pid == $pid2 ]; then
      flag=1
    fi
  done

  if [ $flag == 0 ]; then
    usefull_pids[$index]=$pid;
    index=$((index+1))
  fi
done

echo "The pid of the opened urls are the following:"
echo ${usefull_pids[*]}

sleep 10

#Kανουμε kill ολες τις διεργασιες απο την τελευταια εως την πρωτη αναλογα με τον χρονο εκτελεσης
for ((pid=${#usefull_pids[@]}-1; pid>=0; pid--));do
	kill -9 ${usefull_pids[$pid]}
	#kill την διεργασια
	sleep 10;
	#περιμενει 10 δευτερολεπτα
done


#Aφου κανουμε kill ολες τις διεργασιες, κλεινουμε το chromium
while ps aux | grep -q '[c]hromium'
	do
		kill $(ps aux | grep '[c]hromium' | awk '{print $2}')
	done

