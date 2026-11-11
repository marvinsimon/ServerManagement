#!/bin/sh

exec sh "$(dirname "$0")/compose.sh" up -d "$@"
