# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'pg'

connection = nil

# Databaseに繋ぐ
class Datebase
  def initialize
    @pg_instance = PG.connect(host: 'localhost', user: 'pctapitapitapi', dbname: 'mymemo', port: '5432')
  end

  def connect_to_db
    @pg_instance
  end
end

db_instance = Datebase.new
connection = db_instance.connect_to_db

get '/memos' do
  @memos = connection.exec('SELECT * FROM mymemo ORDER BY id ASC;')
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  title = params[:title]
  content = params[:content]
  connection.exec(
    'INSERT INTO mymemo (title, content) VALUES ($1, $2);', [title, content]
  )
  redirect '/memos'
end

def find_memo(connection, id)
  rows = connection.exec("SELECT * FROM mymemo WHERE id IN (#{id});")
  if rows.first.nil?
    halt erb(:not_found)
  else
    rows.first
  end
end

get '/memos/:id' do
  id = params[:id]
  @memo = find_memo(connection, id)
  erb :show
end

get '/memos/:id/edit' do
  id = params[:id]
  @memo = find_memo(connection, id)
  erb :edit
end

patch '/memos/:id' do
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
  id = params[:id]
  connection.exec('DELETE FROM mymemo WHERE id IN ($1);', [id])
  redirect '/memos'
end

helpers do
  def escape_html(text)
    Rack::Utils.escape_html(text)
  end
end

not_found do
  erb :not_found
end
