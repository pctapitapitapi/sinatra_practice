# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'json'

memos = nil

def open_file
  if File.read('memo.json', 1).nil?
    nil
  else
    JSON.parse(File.read('memo.json'), symbolize_names: true)
  end
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
  if memos.find { |m| m[:id] == params[:id] }
    @memo = memos.find { |m| m[:id] == params[:id] }
    erb :show
  else
    erb :not_found
  end
end

get '/memos/:id/edit' do
  memos = open_file
  @memo = memos.find { |m| m[:id] == params[:id] }
  erb :edit
end

patch '/memos/:id' do
  memos = open_file
  memo = memos.find { |m| m[:id] == params[:id] }
  memo[:title] = params[:title]
  memo[:content] = params[:content]
  memo[:create_at] = Time.now
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
