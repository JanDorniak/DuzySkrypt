#!/bin/bash
# Author           : Jan Dorniak
# Created On       : 6-05-2019
# Last Modified By : Jan Dorniak
# Last Modified On : 15-05-2019
# Version          : v0.2
#
# Description      : Program umożliwia różne operacje na archiwizacji plików.
# Opis
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)

#1. naglowek
#2. komentarze
#3. Odporny na...
#4. Opcje -h -v (pomoc, wersja)
#5. Bloko kodu w funkcjach
#6. Pliki tymczasowe w katalogach

INPUT=/tmp/input.sh.$$
INPUT2=/tmp/input2.sh.$$

#find . -not -path '*/\.*' -type f

OPCJEMENU=(1 "Wypakuj"
	   	   2 "Spakuj"
           3 "Zmień bieżącą ścieżkę"
           4 "Wyświetl zawartość aktualnego folderu"
		   5 "Wyjdź")

function rozpakuj()
{
	#PLIKI=('find . -not -path '*/\.*' -type f')

	readarray -d '' PLIKI < <(find . -not -path '*/\.*' -type f -print0) #zeby nie szukalo w innych folderach

	IT=1
	SPIS=()

	for i in "${PLIKI[@]}"
	do
		SPIS+=($IT "$i")
		IT=$((IT+1))
	done

	#clear
	#echo "${SPIS[@]}"
	#sleep 10

	dialog --title "Wybierz plik na którym chcesz operować (spacją)" --backtitle "tytul" \
	--menu "menu" 0 0 0 "${SPIS[@]}"

	#sprawdzenie rozszerzenia

	dialog --title "Co chcesz zrobić?" \
	--menu "Wybierz:" 0 0 0 \
	"1" "Wypakować" \
	"2" "Wyświetlić zawartość" \
	"3" "Wyświetlić komentarz archiwum" 2>"${INPUT2}"
}


function zmien_sciezke()
{
	dialog --title "Jestes w $PWD" --backtitle "Podaj ścieżkę" \
	--inputbox "Podaj docelową scieżkę" 0 0 2>"${INPUT2}"

	if [ $? -eq 1 ]; then #jesli kliknieto anuluj
		return;
	fi

	FOLDER=$(<"${INPUT2}")

	cd $FOLDER

	return $FOLDER #!!!!
}

function wyswietl_folder()
{
	dialog --
}

while true; do

	dialog --clear --title "Program do archiwizacji" --backtitle "Wersja 0.2" \
	--menu "Wybierz co chcesz zrobić:" 0 0 0 "${OPCJEMENU[@]}" 2>"${INPUT}"

	WYBOR=$(<"${INPUT}")

	case $WYBOR in 
		1)
			rozpakuj
			;;
		2)
			echo "Opcja 2"
			;;
		3) 	
			zmien_sciezke #zrobione
			;;
		4)
			ZAWARTOSC=$(ls) #zrobione #do zrobienia rozmiary 
			dialog --msgbox "$ZAWARTOSC" 0 0
			;;
		*)
			break #zrobione
			;;
	esac

done

clear

[ -f $INPUT ] && rm $INPUT
[ -f $INPUT2 ] && rm $INPUT2

