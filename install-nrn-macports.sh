# #! /bin/bash

MPPREFIX="/opt/local"

test_py_neuron() {
    PYBIN="${MPPREFIX}/bin/python$1"
    if [ -f ${PYBIN} ]; then
	NRN_RESPONSE=$( { ${PYBIN} -c "import neuron"; } 2>&1 )
	case "${NRN_RESPONSE}" in
	    *"ImportError"* ) 
		echo "${NRN_RESPONSE}"
		echo "NEURON Python module wasn't found for ${PYBIN}";;
	    * ) 
		echo "${NRN_RESPONSE}"
		echo "NEURON Python module found for ${PYBIN}"
		echo "You should uninstall this module first."
		read -r -p "Are you sure you want to proceed? [y/N] " response
		case $response in
		    [yY][eE][sS]|[yY]) 
			;;
		    *)
			exit;;
		esac;;
	esac
    fi
}

clean_port() {
    PORT_RESPONSE=$( { port installed $1; } 2>&1 )
    case "${PORT_RESPONSE}" in
        *"$1"* )
            sudo port uninstall $1
            sudo port clean --all $1;;
        * ) 
            ;;
    esac
}

test_port_index() {
    PORT_RESPONSE=$( { port info --line $1; } 2>&1 )
    case "${PORT_RESPONSE}" in
        *Error* )
	    echo "$1 wasn't found in MacPorts; aborting now"
	    exit;;
        * )
            ;;
    esac
}

# MacPorts installed?
if [ -z `which port` ]; then
    echo "Install MacPorts first (http://www.macports.org)"
    exit
fi

# Get Portfiles and scripts
echo "Downloading Portfiles and scripts"
curl --progress-bar -O http://www.stimfit.org/neuron/nrn-macports.tar.gz
tar -xzf nrn-macports.tar.gz
cd nrn-macports
MPPWD=`pwd`

# Install gsed
if [ -z `which gsed` ]; then
    read -r -p "Install gsed from MacPorts (required)? [Y/n] " response
    case $response in
	[nN][oO]|[nN]) 
	    echo "You don't have gsed installed; aborting now"
	    exit
	    ;;
	*)
            sudo port install gsed    
	    ;;
    esac
fi

# Add to MacPorts sources
MPSRCFILE="${MPPREFIX}/etc/macports/sources.conf"
if grep -Fq "${MPPWD}" "${MPSRCFILE}"; then
    echo "${MPPWD} has already been added to ${MPSRCFILE}"
else
    read -r -p "Add ${MPPWD} directory to MacPorts sources (required)? [Y/n] " response
    case $response in
	[nN][oO]|[nN]) 
	    echo "MacPorts sources unchanged; this may cause problems"
	    ;;
	*)
	    MPSRCFILEBAK=$MPSRCFILE.NEURON_`date +"%Y%m%d-%T"`
	    sudo cp ${MPSRCFILE} ${MPSRCFILEBAK}
	    echo "Previous profile backed up to ${MPSRCFILEBAK}"
	    sudo gsed -i '$ i file:\/\/'${MPPWD}'' ${MPSRCFILE}
	    ;;
    esac
fi

test_py_neuron "2.7"
test_py_neuron "3.3"
test_py_neuron "3.4"

# Remove previous installs
clean_port "neuron"
clean_port "neuron-iv"

# Refresh port index
echo "Refreshing MacPorts index (requires admin password)"
sudo portindex

# Make sure that the ports have been added:
test_port_index "neuron"
test_port_index "neuron-iv"

echo ""
echo "Installing openmpi"
sudo port install openmpi-default
sudo port select mpi openmpi-mp-fortran

echo ""
echo "Installing neuron"
sudo port install neuron

# Add NEURON binary directory to PATH
PROFILE="${HOME}/.profile"
echo $PATH | grep -Fq "/Applications/MacPorts/NEURON/nrn/x86_64/bin" && X86_64_PATH=1 || X86_64_PATH=0
echo $PATH | grep -Fq "/Applications/MacPorts/NEURON/nrn/i386/bin" && I386_PATH=1 || I386_PATH=0
if [[ ${X86_64_PATH} -eq 1 || ${I386_PATH} -eq 1 ]]; then
    echo "NEURON binary directory has already been added to your path"
else
    NEURONPATH="export PATH=/Applications/MacPorts/NEURON/nrn/x86_64/bin:/Applications/MacPorts/NEURON/nrn/i386/bin:\$PATH"
    read -r -p "Add NEURON binary directory your PATH (recommended)? [Y/n] " response
    case $response in
	[nN][oO]|[nN]) 
	    ;;
	*)
	    PROFILEBAK=$PROFILE.NEURON_`date +"%Y%m%d-%T"`
	    cp ${PROFILE} ${PROFILEBAK}
	    echo "Previous profile backed up to ${PROFILEBAK}"
	    echo "# Added on `date` for NEURON:" >> ${PROFILE}
	    echo ${NEURONPATH} >> ${PROFILE}
	    echo "# End added for NEURON" >> ${PROFILE}
	    source ${PROFILE}
	    ;;
    esac
fi
