#!/bin/bash
#
# Checks updates and caches result for ${LOG_TIME} minutes.
#
LOG_FILE="/tmp/update_checker.log"
LOG_TIME="10" # in minutes
if ! [ -f "${LOG_FILE}" ] || test `find "${LOG_FILE}" -mmin +${LOG_TIME}`
then
	/usr/lib/update-notifier/apt-check 2>&1 | tee "${LOG_FILE}"
else
	cat "${LOG_FILE}"
fi
