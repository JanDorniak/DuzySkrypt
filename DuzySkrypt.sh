#!/bin/bash
# Author           : Jan Dorniak
# Created On       : 6-05-2019
# Last Modified By : Jan Dorniak
# Last Modified On : 16-05-2019
# Version          : v1.0
#
# Description      : Skrypt umożliwia różne operacje na archiwizacji plików.
# Opis
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)
WERSJA="v1.0, autor: Jan Dorniak 175959"
#1. naglowek
#2. komentarze
#3. Odporny na...
#4. Opcje -h -v (pomoc, wersja)
#5. Bloko kodu w funkcjach
#6. Pliki tymczasowe w katalogach

#tymczasowe pliki na zapisywanie wyborow z dialogu
INPUT=/tmp/input.sh.$$
INPUT2=/tmp/input2.sh.$$
INPUT3=/tmp/input3.sh.$$

OPCJEMENU=(1 "Wypakuj / Podejrzyj zawartość"
	   	   2 "Spakuj"
           3 "Zmień bieżącą ścieżkę"
           4 "Wyświetl zawartość aktualnego folderu"
		   5 "Wyjdź")

function help()
{
	echo "Pomoc "
	echo "----------------"
	echo "1.Wypakowywanie:"
	echo "	Po wybraniu tej opcji proszeni jesteśmy o wybranie pliku, który chcemy"
	echo "	wypakować/podejrzeć. Nastepnie wpisujemy docelową ścieżkę wypakowania."
	echo "	Jeśli chcemy wypakować w bieżącym klikamy anuluj. Następnie jesteśmy"
	echo "	pytani, czy chcemy nadpisywać pliki o tej samej nazwie. Po odpowiedzi"
	echo "	możemy wybrać czy wypakować plik czy tylko podejrzeć zawartość"
	echo "----------------"
	exit
}

function rozpakuj()
{
	readarray -d '' PLIKI < <(find . -not -path '*/\.*' -type f -maxdepth 1 -print0) 

	IT=1 #index 
	SPIS=()

	#przeformatowanie listy plikow na odpowiednia do menu
	for i in "${PLIKI[@]}" 
	do
		SPIS+=($IT "$i")
		IT=$((IT+1))
	done

	#wybranie pliku
	dialog --title "Wybierz plik na którym chcesz operować" --backtitle "Wybór pliku" \
	--menu "Wybierz:" 0 0 0 "${SPIS[@]}" 2>"${INPUT2}"

	if [ $? -eq 1 ]; then #jesli kliknieto anuluj
		return;
	fi

	#folder docelowy
	zmien_sciezke
	SCIEZKA=$FOLDER

	INDEX=$(<"${INPUT2}")
	INDEX=$((INDEX-1))
	PLIK="${PLIKI[INDEX]}"

	#czy nadpisywac
	dialog --title "Czy nadpisywać?" --yesno "Czy nadpisywać pliki?" 0 0

	NADPIS=$?
	NADPISTAR=""
	NADPISZIP="-o"
	NADPISZRAR="-o+"
	if [ $NADPIS -eq 1 ]; then
		NADPISTAR="-k"
		NADPISZIP="-f"
		NADPISZRAR="-o-"
	fi

	#sprawdzenie poprawnosci formatu pliku
	if [ ${PLIK: -4} == ".tar" ]; then
		WYPAKUJ="tar -xf $PLIK -C $SCIEZKA $NADPISTAR"
		ZAWARTOSC="tar -tvf $PLIK"
	elif [ ${PLIK: -7} == ".tar.gz" ]; then
		WYPAKUJ="tar -zxf $PLIK --directory $SCIEZKA $NADPISTAR"
		ZAWARTOSC="tar -ztvf $PLIK"
	elif [ ${PLIK: -8} == ".tar.bz2" ]; then
		WYPAKUJ="tar -jxf $PLIK --directory $SCIEZKA $NADPISTAR"
		ZAWARTOSC="tar -jtvf $PLIK"
	elif [ ${PLIK: -4} == ".zip" ]; then
		WYPAKUJ="unzip $NADPISZIP $PLIK -d $SCIEZKA"
		ZAWARTOSC="unzip -l $PLIK"
	elif [ ${PLIK: -4} == ".rar" ]; then
		WYPAKUJ="unrar x $NADPISZRAR $PLIK $SCIEZKA"
		ZAWARTOSC="unrar l $PLIK"
	else
		dialog --msgbox "ZLY FORMAT PLIKU!" 0 0
		return
	fi

	dialog --clear --title "Co chcesz zrobić?" \
	--menu "Wybierz:" 0 0 0 \
	1 "Wypakować" \
	2 "Wyświetlić zawartość i komentarz" 2>"${INPUT2}"

	if [ $? -eq 1 ]; then #jesli kliknieto anuluj
		return;
	fi

	WYBOR=$(<"${INPUT2}")

	case $WYBOR in 
		1)
			$WYPAKUJ
			;;
		2)
			WARTOSCI=$($ZAWARTOSC)
			dialog --msgbox "$WARTOSCI" 0 0
			;;
	esac
}

function spakuj()
{
	ZMIENNA=()
}

function zmien_sciezke()
{
	dialog --title "Aktualna ścieżka $PWD" --backtitle "Podaj ścieżkę" \
	--inputbox "Wpisz ścieżkę docelową, anuluj pozostawia aktualną ścieżkę" 0 0 2>"${INPUT3}"

	if [ $? -eq 1 ]; then #jesli kliknieto anuluj
		FOLDER=$PWD
		return
	fi

	FOLDER=$(<"${INPUT3}")
}


#sprawdzenie argumentów wywołania
if [ $1 == '-h' ]; then
	help
	exit
elif [ $1 == '-v' ]; then
	echo $WERSJA
	exit
fi


while true; do

	dialog --clear --title "Program do archiwizacji" --backtitle "Wersja 0.2" \
	--menu "Wybierz co chcesz zrobić:" 0 0 0 "${OPCJEMENU[@]}" 2>"${INPUT}"

	WYBOR=$(<"${INPUT}")

	case $WYBOR in 
		1)
			rozpakuj #zrobione
			;;
		2)
			spakuj
			;;
		3) 	
			zmien_sciezke #zrobione
			cd $FOLDER
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
[ -f $INPUT3 ] && rm $INPUT3

