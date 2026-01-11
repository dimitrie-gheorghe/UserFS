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
	
	ls | while read director; do
		k=1
		for utilizator in $utilizatori_activi; do
			if [ "$director" == "$utilizator" ]; then
				k=0
				break
			fi
		done
		if [ "$k" == "1" ]; then
			echo > ./"$director"/procs # golim procs
			ultima_data=$(journalctl -u systemd-logind | grep "$director" | tail -n 1)

			luna=$(echo "$ultima_data" | awk '{print $1}')
			ziua=$(echo "$ultima_data" | awk '{print $2}')
			ora=$(echo "$ultima_data" | awk '{print $3}')
			echo -e "luna = $luna\nziua = $ziua\nora = $ora" > ./"$director"/lastlogin
		fi

	done

	sleep 30 # asteptam 30 de secunde
done
