#! /bin/sh

sudo rm NEURON-macports/PortIndex*
rm NEURON-macports.tar.gz
tar -czf NEURON-macports.tar.gz NEURON-macports
scp NEURON-macports.tar.gz p8210991@home34288459.1and1-data.host:/kunden/homepages/32/d34288459/htdocs/StimfitJ/neuron
