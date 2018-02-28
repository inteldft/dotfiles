#!/bin/sh

mail -s "${2} -- ${1}" troy.j.hinckley@intel.com <<< "" && mail -s "${2} -- ${1}" troyhinckley@gmail.com <<< ""
