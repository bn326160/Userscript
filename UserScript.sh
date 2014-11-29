#!/bin/bash

#Bram Beirens - r0455929 - 2TI1

#Variabelen instellen
#Uitvoermap ontdekken
BASEDIR=$(dirname $0)
#Standaardlijst instellen
FILE=newusers.txt

#Functies aanmaken
#Gebruikers aanmaken
AddUsers() {
  while read line
    do
      USERNAME=$(echo "$line" | cut -d ' ' -f 1)
      PASSWORD=$(echo "$line" | cut -d ' ' -f 2)
      useradd -m -c "aangemaakt door script" $USERNAME
      usermod -p $(echo $PASSWORD | openssl passwd -1 -stdin) $USERNAME
  done < $BASEDIR/$FILE
  echo "Alle gebruikers zijn succesvol toegevoegd en hun wachtwoord is toegewezen."
  exit
}

#Gebruikers wissen
DelUsers() {
  while read line
    do
      USERNAME=$(echo "$line" | cut -d ' ' -f 1)
      userdel -r $USERNAME
  done < $BASEDIR/$FILE
  echo "Alle gebruikers zijn succesvol gewist."
  exit
}

#Intro
clear
printf "Dit script stelt u in staat op eenvoudige wijze een aantea nieuwe gebruikers aan te maken in uw systeem.\nStandaard worden deze gebruikers opgehaald uit het bestand 'newusers.txt'.\nEen alternatief bestand kan geraadpleegd worden door deze als argument op te geven.\nHet model voor iedere regel in het bestand is alsvolgt: '<gebruikersnaam><spatie><wachtwoord>'."
echo
echo

#Nagaan of de gebruiker root is
if [ "$(whoami)" != "root" ]
  then echo "U moet ingelogd zijn als root alvorens dit script uit te voeren." 2>&1
  exit
fi

#Nagaan of er een argument gebruikt wordt, zo ja, dat als newusers.txt-bestand gebruiken
if [ -z $1 ]
  then
    echo "Geen alternatief bestand opgegeven, dit script zal $FILE zoeken." 2>&1
  else
    FILE=$1
    echo "Alternatief bestand opgegeven."
fi

#Nagaan of het al dan niet opegegeven bestand bestaat
if [ -f $BASEDIR/$FILE ];
  then
    echo "Bestand gevonden."
  else
    echo "Bestand $FILE is niet gevonden." 2>&1
    exit
fi

##Nagaan of er een home directory moet aangemaakt worden
# while true; do
#     read -p "Moet er een home directory voor elke gebruiker aangemaakt worden? (J/N?)" jn
#     case $jn in
#         [Jj]* ) AANMAAKREGEL="useradd -m $USERNAME";break;;
#         [Nn]* ) AANMAAKREGEL="useradd $USERNAME";break;;
#         * ) echo "Gelieve ja of neen te antwoorden.";;
#     esac
# done

#Elke gebruiker aanmaken/wissen
while true; do
    read -p "Dienen de gebruikers uit het externe bestand (A)angemaakt of ge(W)ist te worden? U kan ook kiezen een (L)ijst van gebruikers weer te geven. (A/W/L?)" awl
    case $awl in
        [Aa]* ) AddUsers;break;;
		[Ll]* ) tail /etc/passwd | cut -d: -f 1;exit;;
        [Ww]* ) DelUsers;break;;
        * ) echo "Gelieve te kiezen uit (A)anmaken, (W)issen of (L)ijst weergeven.";;
    esac
done