#!/bin/sh

while [ "${1}" ]; do
	sudo chown -R nobody.datausers "${1}"
	find "${1}" -type f -print0 | sudo xargs -0 --no-run-if-empty chmod 664
	find "${1}" -type d -print0 | sudo xargs -0 --no-run-if-empty chmod 775
	shift
done
