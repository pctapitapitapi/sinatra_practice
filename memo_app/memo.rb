# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'json'

memos = nil

def open_file
  JSON.parse(File.read('memo.json'), symbolize_names: true)
end

get '/memos' do
  memos = open_file
  @memos = memos
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  memos = open_file
  memos = [] if memos.nil?
  new_memo = {
    id: SecureRandom.uuid,
    title: sanitizing(params[:title]),
    content: sanitizing(params[:content]),
    create_at: Time.now
  }
  memos << new_memo
  File.open('memo.json', 'w') { |file| JSON.dump(memos, file) }
  redirect '/memos'
end

get '/memos/:id' do
  memos = open_file
  memo = memos.select { |m| m[:id] == params[:id] }
  @id = memo[0][:id]
  @title = memo[0][:title]
  @content = memo[0][:content]
  erb :show
end

get '/memos/:id/edit' do
  memos = open_file
  memo = memos.select { |m| m[:id] == params[:id] }
  @id = memo[0][:id]
  @title = memo[0][:title]
  @content = memo[0][:content]
  erb :edit
end

patch '/memos/:id' do
  memos = open_file
  memo = memos.select { |m| m[:id] == params[:id] }
  memo[0][:title] = sanitizing(params[:title])
  memo[0][:content] = sanitizing(params[:content])
  memo[0][:create_at] = Time.now
  File.open('memo.json', 'w') { |file| JSON.dump(memos, file) }
  redirect '/memos'
end

delete '/memos/:id' do
  memos = open_file
  index_number = memos.index { |n| n[:id] == params[:id] }
  memos.delete_at index_number
  File.open('memo.json', 'w') { |file| JSON.dump(memos, file) }
  redirect '/memos'
end

helpers do
  def sanitizing(text)
    Rack::Utils.escape_html(text)
  end
end

not_found do
  erb :not_found
end
