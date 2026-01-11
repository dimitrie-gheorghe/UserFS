#!/bin/bash

# cream directorul radacina, in caz ca nu exista deja
# (asta are sens in cazul rularilor succesive ale programului)
if [ ! -d "director_radacina" ]; then
	mkdir "director_radacina"
fi

# intram in directorul radacina, deoarece aici vom face toate operatiunile
cd director_radacina

echo "Scriptul UserFS a pornit. Apasa Ctrl+C pentru a il opri"

#loop-ul principal
while true; do

	# aici obtinem lista utilizatorilor activi din care extragem doar numele ($1)
	# uniq inseamna ca eliminam duplicatele
	utilizatori_activi=$(who | awk '{print $1}' | uniq)
	
	# procesarea utilizatorilor activi
	for nume in $utilizatori_activi; do

		# cream un director pentru fiecare utilizator activ, in caz ca nu exista deja
		if [ ! -d "$nume" ]; then
			mkdir "$nume"
		fi

		# intram in directorul utilizatorului, pentru a folosi un path mai scurt in urmatoarele comenzi
		cd "$nume"

		# stergem fisierul lastlogin, pentru ca nu mai e nevoie de el, din moment ce user-ul e conectat
		# lastlogin poate exista in cazul unei deconectari anterioare conectarii curente
		if [ -f "lastlogin" ]; then
			rm "lastlogin"
		fi

		# obtinem lista proceselor utilizatorului
		procese=$(ps -u "$nume")

		# listam procesele utilizatorului in fisierul procs
		echo "$procese" > ./procs

		# iesim din directorul utilizatorului
		cd ..
	done
	
	# procesarea utilizatorilor care s-au deconectat
	ls | while read director; do

		# forta bruta pentru a determina daca un utilizator s-a deconectat
		# luam fiecare director din directorul radacina si verificam daca se afla in lista utilizatorilor activi din momentul curent
		k=1
		for utilizator in $utilizatori_activi; do
			if [ "$director" == "$utilizator" ]; then
				k=0
				break
			fi
		done
		
		# cazul in care utilizatorul s-a deconectat
		if [ "$k" == "1" ]; then
		
			# golim procs
			echo > ./"$director"/procs
			
			# obtinerea datii ultimei sesiuni in sistem
			ultima_data=$(journalctl -u systemd-logind | grep "$director" | tail -n 1)

			# extragerea lunii
			luna=$(echo "$ultima_data" | awk '{print $1}')

			# extragerea zilei
			ziua=$(echo "$ultima_data" | awk '{print $2}')

			# extragerea orei, desi data ar putea insemna doar luna si ziua
			ora=$(echo "$ultima_data" | awk '{print $3}')

			# scrierea in fisierul lastlogin. -e ofera posibilitatea de a folosi caractere speciale (\n)
			echo -e "luna = $luna\nziua = $ziua\nora = $ora" > ./"$director"/lastlogin
		fi

	done

	# asteptam 30 de secunde
	sleep 30
done
