#!/bin/bash
DIR=`dirname $0`
source $DIR/config-dev.sh
export ECHIDNA_REDIS_NAMESPACE="e:${USER}:d"
echo "redis namespace: ${ECHIDNA_REDIS_NAMESPACE}"
redis-cli lpush ${ECHIDNA_REDIS_NAMESPACE}:streaming/messages '{"type":"add_user","body":{"id":"user-1","type":"tencent","birth_year":2000,"gender":"f","city":"shanghai"}}'
redis-cli lpush ${ECHIDNA_REDIS_NAMESPACE}:streaming/messages '{"type":"add_user_to_group","body":{"group_id":"group-1","user_id":"user-1","user_type":"tencent"}}'
redis-cli lpush ${ECHIDNA_REDIS_NAMESPACE}:streaming/messages '{"type":"add_tweet","body":{"user_id":"user-1","user_type":"tencent","text":"我是中国人","id":"abc","url":"http://t.qq.com/t/abc","timestamp":1361494534}}'
curl "localhost:${ECHIDNA_STREAMING_PORT}?group_id=group-1&interval=minute&start_time=2013-02-22T00:54:00Z&end_time=2013-02-22T00:56:00Z"
