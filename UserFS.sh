#!/bin/bash

if [ ! -d "director_radacina" ]; then
	mkdir "director_radacina"
fi

echo "Scriptul UserFS a pornit. Apasa Ctrl+C pentru a il opri"

while true; do
	utilizatori_activi=$(who | awk '{print $1}' | sort | uniq)
	echo "$utilizatori_activi"
	break
done
