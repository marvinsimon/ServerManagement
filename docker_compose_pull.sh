#!/bin/sh

exec sh "$(dirname "$0")/compose.sh" pull "$@"
