#! /bin/bash

NRNVERSION="7.4"
NRNREL="rel-1341"
IVVERSION="19"
MASTERSITE="http://www.stimfit.org/neuron"
# PATCHSITE="http://www.stimfit.org/neuron"

NRNDISTNAME="nrn-${NRNVERSION}.${NRNREL}.tar.gz"
IVDISTNAME="iv-${IVVERSION}.tar.gz"
# PATCHNAME="patch-destdir"

if [ ! -f ${NRNDISTNAME} ]
then
    wget ${MASTERSITE}/${NRNDISTNAME}
fi

if [ ! -f ${IVDISTNAME} ]
then
    wget ${MASTERSITE}/${IVDISTNAME}
fi

# if [ ! -f ${PATCHNAME} ]
# then
#     wget ${PATCHSITE}/${PATCHNAME}
# fi

NRNRMD160=`openssl rmd160 -r ${NRNDISTNAME} | awk '{print $1;}'`
NRNSHA256=`openssl sha256 -r ${NRNDISTNAME} | awk '{print $1;}'`
IVRMD160=`openssl rmd160 -r ${IVDISTNAME} | awk '{print $1;}'`
IVSHA256=`openssl sha256 -r ${IVDISTNAME} | awk '{print $1;}'`
# PATCHRMD160=`openssl rmd160 -r ${PATCHNAME} | awk '{print $1;}'`
# PATCHSHA256=`openssl sha256 -r ${PATCHNAME} | awk '{print $1;}'`

echo "rmd160 for nrn:" ${NRNRMD160}
echo "sha256 for nrn:" ${NRNSHA256}
echo "rmd160 for iv:" ${IVRMD160}
echo "sha256 for iv:" ${IVSHA256}
# echo "rmd160 for patch:" ${PATCHRMD160}
# echo "sha256 for patch:" ${PATCHSHA256}

GSED=`which gsed`
if [ "${GSED}" = "" ]
then
    GSED=`which sed`
fi

${GSED} 's/NRNRMD160/'${NRNRMD160}'/g' science/neuron/Portfile.in > science/neuron/Portfile
${GSED} -i 's/NRNSHA256/'${NRNSHA256}'/g' science/neuron/Portfile
${GSED} -i 's/VERSION/'${NRNVERSION}'/g' science/neuron/Portfile
${GSED} -i 's/REL/'${NRNREL}'/g' science/neuron/Portfile
# ${GSED} -i 's/PATCHRMD160/'${PATCHRMD160}'/g' science/neuron/Portfile
# ${GSED} -i 's/PATCHSHA256/'${PATCHSHA256}'/g' science/neuron/Portfile
${GSED} 's/RMD160/'${IVRMD160}'/g' science/neuron-iv/Portfile.in > science/neuron-iv/Portfile
${GSED} -i 's/SHA256/'${IVSHA256}'/g' science/neuron-iv/Portfile
${GSED} -i 's/IVVERSION/'${IVVERSION}'/g' science/neuron-iv/Portfile

sudo portindex
sudo port uninstall neuron
sudo port clean --all neuron
# sudo port uninstall neuron-iv
# sudo port clean --all neuron-iv
