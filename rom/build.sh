#!/bin/bash

beebasm -i AtomWifi.asm -v > atomwifi-output.lst

cp atomwifi.rom ~/Downloads/AtomWifi.bin

echo Creating production files
ver=`grep ".romversion" AtomWifi.asm | cut -d'"' -f 2`
crc=`../crc/crc16 atomwifi.rom`

echo VER=$ver > atomwifi-version.txt
echo CRC=$crc >> atomwifi-version.txt
cp atomwifi.rom atomwifi-latest.bin
cp ATOMWIFI.ATM /home/roland/Atomulator/mmc

