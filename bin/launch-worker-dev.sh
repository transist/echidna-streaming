#!/bin/bash
DIR=`dirname $0`
source $HOME/.rvm/scripts/rvm
. $DIR/config-dev.sh

echo "redis namespace: ${ECHIDNA_REDIS_NAMESPACE}"
ruby $DIR/../bin/worker.rb
