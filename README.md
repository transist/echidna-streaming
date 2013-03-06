# echidna-streaming

## Setup

install redis-server on debian

```bash
sudo apt-get install redis-server
```

or mac

```bash
brew install redis
```

### Ruby Environment Setup

<https://github.com/transist/echidna/wiki/Ruby-Environment-Setup>

## Streaming workeer

start worker

```bash
ECHIDNA_ENV=development ECHIDNA_REDIS_HOST=127.0.0.1 ECHIDNA_REDIS_PORT=6379 ruby bin/worker.rb
```

add a user

```bash
redis-cli lpush e:flyerhzm:d:streaming/messages '{"type":"add_user","body":{"id":"user-1","type":"tencent","birth_year":2000,"gender":"f","city":"shanghai"}}'
```

add user to group

```bash
redis-cli lpush e:flyerhzm:d:streaming/messages '{"type":"add_user_to_group","body":{"group_id":"group-1","user_id":"user-1","user_type":"tencent"}}'
```

add tweet

```bash
redis-cli lpush e:flyerhzm:d:streaming/messages '{"type":"add_tweet","body":{"user_id":"user-1","user_type":"tencent","text":"我是中国人","id":"abc","url":"http://t.qq.com/t/abc","timestamp":1361494534}}'
```

## CLI

Seed cities, tiers and groups data

```bach
ECHIDNA_ENV=development ECHIDNA_REDIS_HOST=127.0.0.1 ECHIDNA_REDIS_PORT=6379 ruby bin/init_groups.rb
```

Query trends

```bash
ECHIDNA_ENV=development ECHIDNA_REDIS_HOST=127.0.0.1 ECHIDNA_REDIS_PORT=6379 ruby bin/trends_test.rb group-1 minute 2013-02-22T00:00:00Z 2013-02-22T01:30:00Z
```

Start trends server

```bash
ECHIDNA_ENV=development ECHIDNA_STREAMING_IP=0.0.0.0 ECHIDNA_STREAMING_PORT=9000 ECHIDNA_REDIS_HOST=127.0.0.1 ECHIDNA_REDIS_PORT=6379  ECHIDNA_STREAMING_DAEMON=true ruby trends.rb
```

## APIs

Query trends

```bash
curl "localhost:9000?group_id=group-1&interval=minute&start_time=2013-02-22T00:00:00Z&end_time=2013-02-22T01:30:00Z"

{
  "2013-02-22T00:55":[
    {"word":"中国人","count":1,"source":"http://t.qq.com/t/abc"},
    {"word":"我是","count":1,"source":"http://t.qq.com/t/abc"}
  ]
}

curl "localhost:9000?group_id=group-1&interval=hour&start_time=2013-02-22T00:00:00Z&end_time=2013-02-22T01:00:00Z"

{
  "2013-02-22T00":[
    {"word":"中国人","count":1,"source":"http://t.qq.com/t/abc"},
    {"word":"我是","count":1,"source":"http://t.qq.com/t/abc"}
  ]
}
```

Query group for echidna-spider

```bash
curl "http://localhost:9000/get_group_ids?gender=female&birth_year=1993&city=%E4%B8%8A%E6%B5%B7"

{"ids":["group-1","group-2"]}
```

Query group for echidna-api

```bash
curl "http://localhost:9000/group_id?gender=Women&birth_year=18-&tier_id=tier-1"

{"id":"group-1"}
```

Fetch all tiers

```bash
curl http://localhost:62303/tiers

[{"name":"Tier 1","id":"tier-1","cities":["北京","上海","深圳","天津","重庆","广州"]},{"name":"Other Tier","id":"tier-other","cities":[]},{"name":"Tier 2","id":"tier-2","cities":["佛山","东莞","温州","厦门","武汉","贵阳","宁波","长沙","唐山","哈尔滨","南京","呼和浩特","青岛","郑州","昆明","常州","无锡","包头","烟台","南通","兰州","杭州","南昌","长春","济南","西安","准二线","石家庄","太原","福州","乌鲁木齐","成都","大连","合肥","南宁","邯郸","苏州","沈阳","徐州","泉州"]}]
```

Fetch all groups

```bash
curl http://localhost:62303/groups

[{"name":"Group
1","gender":"female","start_birth_year":"1989","end_birth_year":"1995","city":"上海","id":"group-1"},{"name":"Group
2","gender":"male","start_birth_year":"1996","end_birth_year":"2002","tier-id":"tier-2","id":"group-2"}]
```

## Test

```bash
bundle exec rspec spec/
```
