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

OPCJEMENU=(1 "Wypakuj"
	   	   2 "Spakuj"
           3 "Zmień bieżącą ścieżkę"
           4 "Wyświetl zawartość aktualnego folderu"
		   5 "Wyjdź")

function rozpakuj()
{
	dialog --title "Co chcesz zrobić?" \
	--menu "Wybierz:" 0 0 0 \
	1 "Zwykle rozpakowanie" \
	2 "CI" \
	3 "ddd" \
	4 "{ch[6]}" 2>"${INPUT2}"
}


function zmien_sciezke()
{
	dialog --title "Jestes w ${PWD}" --backtitle "Podaj ścieżkę" \
	--inputbox "Podaj docelową scieżkę" 0 0 2>"${INPUT2}"

	if [ $? -eq 1 ]; then
		return;
	fi

	FOLDER=$(<"${INPUT2}")

	cd $FOLDER

	return $FOLDER
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
			ZAWARTOSC=$(ls) #zrobione
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

