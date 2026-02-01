#!/bin/bash

service nginx start
/css/srcds_run -console -game cstrike \
    +sv_downloadurl "$DOWNLOAD_URL" \
    +maxplayers "${MAXPLAYERS:-32}" \
    +port "${PORT:-27015}" \
    +map "${MAP:-de_train}" \
    +exec server.cfg
