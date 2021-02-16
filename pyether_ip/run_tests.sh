#!/bin/bash
rm src/ether_ip/ether_ip.c
rm src/ether_ip/ether_ip.h
rm src/ether_ip/eip_bool.h

cp ../ether_ipApp/src/ether_ip.c src/ether_ip/ether_ip.c
cp ../ether_ipApp/src/ether_ip.h src/ether_ip/ether_ip.h
cp ../ether_ipApp/src/eip_bool.h src/ether_ip/eip_bool.h

tox --recreate

