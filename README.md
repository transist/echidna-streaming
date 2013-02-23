# echidna-streaming

# Setup

install redis-server on debian

```bash
sudo apt-get install redis-server
```

or mac

```bash
brew install redis
```

install rvm for ruby

```bash
curl -L https://get.rvm.io | bash -s stable --ruby
source ~/.rvm/scripts/rvm
echo 'rvm_trust_rvmrcs_flag=1' > ~/.rvmrc
```

install dependencies for ruby

```bash
rvm requirements
```

then followed the notes

install ruby

```bash
rvm install 1.9.3-p327-falcon --patch falcon
rvm use 1.9.3-p327-falcon --default
```

install bundler (ruby gems management)

```bash
rvm gemset use global
gem install bundler
rvm gemset use default
```

copy .rvmrc.example to .rvmrc and customize it to conform your ruby setup if necessary
then install app dependencies

```bash
cd <app path>
cp .rvmrc.example .rvmrc
bundle install
```

## Streaming workeer

start worker

```bash
ruby lib/worker.rb
```

add a user

```bash
redis-cli publish add_user '{"id":"user-1","type":"tencent","birth_year":2000,"gender":"f","city":"shanghai"}'
```

add a group

```bash
redis-cli publish add_group '{"id":"group-1","name":"Group 1"}'
```

add user to group

```bash
redis-cli publish add_user_to_group '{"group_id":"group-1","user_id":"user-1","user_type":"tencent"}'
```

add tweet

```bash
redis-cli publish add_tweet '{"user_id":"user-1","user_type":"tencent","text":"我是中国人","id":"abc","url":"http://t.qq.com/t/abc","timestamp":"20130222005534"}'
```

## Query trends

start trends server

```bash
ruby trends.rb
```

query trends

```bash
curl
localhost:9000?group_id=group-1&interval=minute&start_timestamp=20130222000000&end_timestamp=20130222013000

{
  "20130222005500":[
    {"word":"中","count":2,"source":"http://t.qq.com/t/efg"},
    {"word":"我","count":2,"source":"http://t.qq.com/t/efg"},
    {"word":"国","count":2,"source":"http://t.qq.com/t/efg"},
    {"word":"在","count":1,"source":"http://t.qq.com/t/efg"},
    {"word":"人","count":1,"source":"http://t.qq.com/t/efg"},
    {"word":"是","count":1,"source":"http://t.qq.com/t/efg"}
  ],
  "20130222005700":[
    {"word":"上","count":1,"source":"http://t.qq.com/t/efg"},
    {"word":"中","count":1,"source":"http://t.qq.com/t/efg"},
    {"word":"国","count":1,"source":"http://t.qq.com/t/efg"},
    {"word":"在","count":1,"source":"http://t.qq.com/t/efg"},
    {"word":"海","count":1,"source":"http://t.qq.com/t/efg"}
  ]
}

curl localhost:9000?group_id=group-1&interval=hour&start_timestamp=20130222000000&end_timestamp=20130222010000

{
  "20130222000000":[
    {"word":"国","count":3,"source":"http://t.qq.com/t/efg"},
    {"word":"中","count":3,"source":"http://t.qq.com/t/efg"},
    {"word":"我","count":2,"source":"http://t.qq.com/t/efg"},
    {"word":"在","count":2,"source":"http://t.qq.com/t/efg"},
    {"word":"上","count":1,"source":"http://t.qq.com/t/efg"},
    {"word":"人","count":1,"source":"http://t.qq.com/t/efg"},
    {"word":"是","count":1,"source":"http://t.qq.com/t/efg"},
    {"word":"海","count":1,"source":"http://t.qq.com/t/efg"}
  ]
}
```
