#!/bin/bash
DIR=`dirname $0`
source $HOME/.rvm/scripts/rvm
. $DIR/config-dev.sh

export ECHIDNA_REDIS_NAMESPACE="e:${USER}:d"
echo "redis namespace: ${ECHIDNA_REDIS_NAMESPACE}"
$DIR/../bin/worker
