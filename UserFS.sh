#!/bin/bash

if [ ! -d "director_radacina" ]; then
	mkdir "director_radacina" # cream directorul radacina, in caz ca nu exista deja
fi

cd director_radacina

echo "Scriptul UserFS a pornit. Apasa Ctrl+C pentru a il opri"

while true; do
	utilizatori_activi=$(who | awk '{print $1}' | uniq) #uniq inseamna ca eliminam duplicatele
	
	for nume in $utilizatori_activi; do
		if [ ! -d "$nume" ]; then
			mkdir "$nume" # cream un director pentru fiecare utilizator activ, in caz ca nu exista deja
		fi
		
		cd "$nume"
		if [ -f "lastlogin" ]; then
			rm "lastlogin" # daca user-ul e activ, nu mai e nevoie de lastlogin
		fi
		procese=$(ps -u "$nume")
		echo "$procese" > ./procs # listam procesele utilizatorului in fisierul procs
		cd ..
	done

	break
	sleep 30 # asteptam 30 de secunde. deocamdata, nu se ajunge aici, pentru ca avem un break
done
