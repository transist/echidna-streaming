#!/bin/bash
. /etc/systemd/conf.d/echidna
redis-cli publish ${ECHIDNA_REDIS_NAMESPACE}:add_user '{"id":"user-1","type":"tencent","birth_year":2000,"gender":"f","city":"shanghai"}'
redis-cli publish ${ECHIDNA_REDIS_NAMESPACE}:add_group '{"id":"group-1","name":"Group 1"}'
redis-cli publish ${ECHIDNA_REDIS_NAMESPACE}:add_user_to_group '{"group_id":"group-1","user_id":"user-1","user_type":"tencent"}'
redis-cli publish ${ECHIDNA_REDIS_NAMESPACE}:add_tweet '{"user_id":"user-1","user_type":"tencent","text":"我是中国人","id":"abc","url":"http://t.qq.com/t/abc","timestamp":"20130222005534"}'
curl "localhost:${ECHIDNA_STREAMING_PORT}?group_id=group-1&interval=minute&start_timestamp=20130222000000&end_timestamp=20130222013000"

