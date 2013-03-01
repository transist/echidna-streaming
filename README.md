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
ECHIDNA_STREAMING_ENV=development ECHIDNA_REDIS_HOST=127.0.0.1 ECHIDNA_REDIS_PORT=6379 ECHIDNA_REDIS_NAMESPACE=e:d ruby bin/worker.rb
```

add a user

```bash
redis-cli publish e:d:add_user '{"id":"user-1","type":"tencent","birth_year":2000,"gender":"f","city":"shanghai"}'
```

add a group

```bash
redis-cli publish e:d:add_group '{"id":"group-1","name":"Group 1"}'
```

add user to group

```bash
redis-cli publish e:d:add_user_to_group '{"group_id":"group-1","user_id":"user-1","user_type":"tencent"}'
```

add tweet

```bash
redis-cli publish e:d:add_tweet '{"user_id":"user-1","user_type":"tencent","text":"我是中国人","id":"abc","url":"http://t.qq.com/t/abc","timestamp":"20130222005534"}'
```

## CLI

Query trends

```bash
ECHIDNA_STREAMING_ENV=development ECHIDNA_REDIS_HOST=127.0.0.1 ECHIDNA_REDIS_PORT=6379 ECHIDNA_REDIS_NAMESPACE=e:d ruby bin/trends_test.rb group-1 minute 20130222000000 20130222013000
```

Start trends server

```bash
ECHIDNA_STREAMING_ENV=development ECHIDNA_STREAMING_IP=0.0.0.0 ECHIDNA_STREAMING_PORT=9000 ECHIDNA_REDIS_HOST=127.0.0.1 ECHIDNA_REDIS_PORT=6379 ECHIDNA_REDIS_NAMESPACE=e:d ECHIDNA_STREAMING_DAEMON=true ruby trends.rb
```

Seed cities, tiers and groups data

```bach
ECHIDNA_STREAMING_ENV=development ECHIDNA_REDIS_HOST=127.0.0.1 ECHIDNA_REDIS_PORT=6379 ECHIDNA_REDIS_NAMESPACE=e:d ruby bin/init_groups.rb
```

## APIs

Query trends

```bash
curl "localhost:9000?group_id=group-1&interval=minute&start_timestamp=20130222000000&end_timestamp=20130222013000"

{
  "20130222005534":[
    {"word":"中国人","count":1,"source":"http://t.qq.com/t/abc"},
    {"word":"我是","count":1,"source":"http://t.qq.com/t/abc"}
  ]
}

curl "localhost:9000?group_id=group-1&interval=hour&start_timestamp=20130222000000&end_timestamp=20130222010000"

{
  "2013022200553":[
    {"word":"中国人","count":1,"source":"http://t.qq.com/t/abc"},
    {"word":"我是","count":1,"source":"http://t.qq.com/t/abc"}
  ]
}
```

Query group

```bash
curl "http://localhost:9000/get_group_ids?gender=female&birth_year=1993&city=%E4%B8%8A%E6%B5%B7"

{"ids":["group-1","group-2"]}
```

## Test

```bash
bundle exec rspec spec/
```
