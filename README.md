# Name

Sinatra memo app

# Requirement

ruby 3.0.2
sinatra (2.1.0)
sinatra-contrib (2.1.0)
psql (PostgreSQL) 14.0

# Usage
## How to set up
- connect to PostgreSQL
- create database mymemo
- create table mymemo
```bash
CREATE TABLE mymemo (
        id SERIAL,
        title TEXT,
        content TEXT,
        PRIMARY KEY (id)
);
```

## How to connect
```bash
git clone
cd memo_app
ruby memo.rb
```
And open http://localhost:4567/memos
