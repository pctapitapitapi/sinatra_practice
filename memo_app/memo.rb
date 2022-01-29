# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'json'
require 'cgi'

memos = nil

def open_file
  begin
    JSON.parse(File.read('memo.json'), symbolize_names: true)
  rescue JSON::ParserError => e
    puts "ファイルが空です。ERROR: #{e}"
  end
end

def find_memo(memos, id)
  if (memo = memos.find { |m| m[:id] == params[:id] })
    return memo
  end
  halt erb(:not_found)
end

get '/memos' do
  @memos = open_file
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  memos = open_file
  new_memo = {
    id: SecureRandom.uuid,
    title: params[:title],
    content: params[:content],
    create_at: Time.now
  }
  memos << new_memo
  File.open('memo.json', 'w') { |file| JSON.dump(memos, file) }
  redirect '/memos'
end

get '/memos/:id' do
  memos = open_file
  @memo = find_memo(memos, params[:id])
  erb :show
end

get '/memos/:id/edit' do
  memos = open_file
  @memo = find_memo(memos, params[:id])
  erb :edit
end

patch '/memos/:id' do
  memos = open_file
  memo = find_memo(memos, params[:id])
  memo[:title] = params[:title]
  memo[:content] = params[:content]
  File.open('memo.json', 'w') { |file| JSON.dump(memos, file) }
  redirect '/memos'
end

delete '/memos/:id' do
  memos = open_file
  memos.delete_if { |n| n[:id] == params[:id] }
  File.open('memo.json', 'w') { |file| JSON.dump(memos, file) }
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
