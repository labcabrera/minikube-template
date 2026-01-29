#!/bin/bash

echo | openssl s_client -showcerts -servername sample-users-api.local -connect sample-users-api.local:443 2>/dev/null | openssl x509 -noout -text
