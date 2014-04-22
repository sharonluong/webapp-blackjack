require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
	"Hello!"
end

get '/new_game' do
	erb :new_game
end

