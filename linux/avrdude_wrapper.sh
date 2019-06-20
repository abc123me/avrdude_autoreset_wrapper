#/bin/bash

# Wrapper for avrdude performing automatic reset to bootloader
# in arduino usb devices like leonardo and lilypad usb
#
# Version: 1.5
# Date: June 19th 2019
# Author: Jeremiah B. Lowe (jeremiahbl@protonmail.com)
#
# Based on arduino-leonardo-uploader from gotzl found here:
# https://github.com/gotzl/avrdude_autoreset_wrapper
# based on arduino-leonardo-uploader from p1ne found here:
# https://github.com/p1ne/arduino-leonardo-uploader
# based on leonardoUploader from vanbwodonk found here:
# https://github.com/vanbwodonk/leonardoUploader
#
# Todo:
# Add device identifiers of remaining usb arduinos


# list of devices that need the reset to bootloader
applicable_devices="Arduino_LLC_Arduino_Leonardo"


args=""
port=""
prog=""
while [ $# -gt 0 ]; do
	s="${1:0:2}"
    case "$s" in
		-P) # Set port, could be in form -P/dev/ttyXXX or -P /dev/ttyXXX
			if [ ${#1} -eq 2 ]; then # Argument form -P /dev/ttyXXX
				shift
				if [ $# -gt 0 ]; then 
					port=$1; 
				fi
			else # Argument form -P/dev/ttyXXX
				port=${1:2};
			fi
			shift
			;;
		-c) # Set programmer, could be in form -cPROG, or -c PROG
			args="$args $1"
			if [ ${#1} -eq 2 ]; then # Argument form -c PROG
				shift
				if [ $# -gt 0 ]; then
					args="$args $1"
					prog=$1
				fi
			else # Argument form -cPROG
				prog=${1:2}
			fi
			shift
			;;
		*) # Normal arguments
			args="$args $1"
			shift
			;;
    esac
done


# Usage: resolve <port/identity> <2>
# 1 - Whether or not to get the port or identifier
# 2 - Device identifier (eg. "STLinkV2") or device name (eg. "/dev/ttyACM0") used in lookup
function resolve {
	# Search sysfs for USB busses/devices
	for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
		syspath="${sysdevpath%/dev}" # Trim off trailing /dev
		devname=`udevadm info -q name -p "$syspath"` # Get the device name (/dev entry)
		if [[ "$devname" == "bus/"* ]]; then continue; fi # devname is a USB bus not a USB device
		identity=`udevadm info -q property -p "$syspath" | grep "ID_SERIAL="`
		if [ -z "$identity" ]; then continue; fi
		identity=${identity:10} # Remove leading ID_SERIAL=
		if [ "$1" = "port" ] && [ "$identity" = "$2" ]; then echo /dev/$devname; fi
		if [ "$1" = "identity" ] && [ "/dev/$devname" = "$2" ]; then echo $identity; fi	        
	done
}

# get directory of this script to forward command to avrdude and leoreset
DIR=$( dirname "${BASH_SOURCE[0]}" )

if [ "$prog" = "avr109" ]; then
	ident=`resolve identity "$port"`
	echo "Found $ident"
	
	for dev in $applicable_devices; do
		if [ "$ident" = "$dev" ]; then
			echo "stty -F $port 1200"
			stty -F $port 1200
			sleep 0.5
			break
		fi
	done
fi

# forward to avrdude for the actual programming
echo "avrdude $args -P$port"
$DIR/avrdude $args -P$port
