#!/bin/bash
DIR=`dirname $0`
source $HOME/.rvm/scripts/rvm
. $DIR/config-dev.sh
echo $ECHIDNA_ENV
$DIR/../bin/trends
