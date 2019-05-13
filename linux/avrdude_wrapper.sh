#/bin/bash

# Wrapper for avrdude performing automatic reset to bootloader
# in arduino usb devices like leonardo and lilypad usb
#
# Version: 1.0
# Date: 11.05.2019
# Author: gotzl
#
# Based on arduino-leonardo-uploader from p1ne found here:
# https://github.com/p1ne/arduino-leonardo-uploader
# and the leonardoUploader from vanbwodonk found here:
# https://github.com/vanbwodonk/leonardoUploader
#
# Todo:
# Add device identifiers of remaining usb arduinos


# list of devices that need the reset to bootloader
applicable_devices="Arduino_LLC_Arduino_Leonardo"


args=""
port=""
prog=""
while test $# -gt 0; do
    case "${1:0:2}" in
    -P)
    	# argument like -P /dev/ttyXX
    	if test ${#1} -eq 2; then
        	shift
	        if test $# -gt 0; then
                port=$1
            fi
        # argument like -P/dev/ttyXX
        else
        	port=${1:2}
        fi
        shift
    	;;
    -c)
    	# add to arguments list
    	args="$args $1"
    	
    	# argument like -c avr109
    	if test ${#1} -eq 2; then
        	shift
	        if test $# -gt 0; then
	        	args="$args $1"
                prog=$1
            fi
        # argument like -cavr109
        else
        	prog=${1:2}
        fi
    	shift
    	;;
    *)
    	args="$args $1"
    	shift
        ;;
    esac
done


# get the device ident corresponding to a port or 
# the port corresponding to a device ident  
function resolve {
	for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
	    (
	     	syspath="${sysdevpath%/dev}"
	        devname="$(udevadm info -q name -p $syspath)"
	        [[ "$devname" == "bus/"* ]] && continue
	        eval "$(udevadm info -q property --export -p $syspath)"
	        [[ -z "$ID_SERIAL" ]] && continue
	        
	        if [ "$2" = "port" ]; then
		        if [ "$ID_SERIAL" = "$1" ]; then
		        	echo /dev/$devname;
		        fi
	        fi
	        
	        if [ "$2" = "ident" ]; then
	        	if [ "/dev/$devname" = "$1" ]; then
	        		echo $ID_SERIAL;
	        	fi
	        fi	        
	    )
	done
}

# get directory of this script to forward command to avrdude and leoreset
DIR=$( dirname "${BASH_SOURCE[0]}" )

if [ "$prog" = "avr109" ]; then
	ident=$(resolve $port "ident")
	echo "Found $ident"
	
	for dev in $applicable_devices; do
		if [ "$ident" = "$dev" ]; then
			#$DIR/leoreset $port
			stty -F $port 1200
			sleep 2
			
			# get the port again, it could've changed ?
			port=$(resolve $ident "port")
		fi
	done
fi

# forward to avrdude for the actual programming
$DIR/avrdude $args -P$port