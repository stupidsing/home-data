#!/bin/bash

KENCHIDIR=stupidsing.no-ip.org:.
OPTIONS="-avz --size-only"
#OPTIONS="-avz --size-only --delete --delete-excluded"

echo storey/phones docs medias oldies | tr " " "\n" | xargs -I {} rsync ${OPTIONS} /data/{}/ ${KENCHIDIR}/data/{}/
rsync ${OPTIONS} /data/photographs\ \&\ memories/ ${KENCHIDIR}/data/photographs/
