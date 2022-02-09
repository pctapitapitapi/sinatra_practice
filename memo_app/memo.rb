# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'pg'

def open_db
  PG.connect(host: 'localhost', user: 'pctapitapitapi', dbname: 'mymemo', port: '5432')
end

# def find_memo(connection, id)
#   if (memo = connection.exec("SELECT * FROM mymemo WHERE id IN ('#{params[:id]}')"))
#     memo
#   else
#     halt erb(:not_found)
#   end
# end

get '/memos' do
  connection = open_db
  if connection.nil?
    create_table_sql =
      'CREATE TABLE mymemo (
        id SERIAL,
        title TEXT,
        content TEXT,
        PRIMARY KEY (id)
      );'
    @memos = connection.exec(create_table_sql)
  else
    @memos = connection.exec('SELECT * FROM mymemo ORDER BY id ASC;')
  end
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  connection = open_db
  title = params[:title]
  content = params[:content]
  connection.exec(
    'INSERT INTO mymemo (title, content) VALUES ($1, $2);', [title, content]
  )
  redirect '/memos'
end

get '/memos/:id' do
  connection = open_db
  id = params[:id]
  @memo = connection.exec('SELECT * FROM mymemo WHERE id IN ($1);', [id])
  erb :show
end

get '/memos/:id/edit' do
  connection = open_db
  id = params[:id]
  @memo = connection.exec('SELECT * FROM mymemo WHERE id IN ($1);', [id])
  erb :edit
end

patch '/memos/:id' do
  connection = open_db
  title = params[:title]
  content = params[:content]
  id = params[:id]
  connection.exec(
    'UPDATE mymemo
    SET title = $1,
    content = $2
    WHERE id IN ($3);', [title, content, id]
  )
  redirect '/memos'
end

delete '/memos/:id' do
  connection = open_db
  id = params[:id]
  connection.exec('DELETE  FROM mymemo WHERE id IN ($1);', [id])
  redirect '/memos'
end

not_found do
  erb :not_found
end
