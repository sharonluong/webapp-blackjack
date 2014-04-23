require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
	redirect '/new_game'
end

get '/new_game' do
	erb :new_game
end

