require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do

	def calculate_total(cards)
		arr = cards.map{|e| e[1]}

		total = 0
		arr.each do |a|
			if a == 'A'
				total += 11
			elsif a.to_i == 0
				total += 10
			else
				total += a.to_i
			end
		end
		arr.select{|e| e == 'A'}.count.times do
			if total > 21
				total -=10
			end
		end
		total
	end

end

get '/' do
	redirect '/new_game'
end

get '/new_game' do
	erb :new_game
end

post '/new_game' do
	session[:player_name] = params[:player_name]
	redirect '/game'
end

get '/game' do
	suits = %w[diamonds clubs hearts spades]
	cards = %w[A 2 3 4 5 6 7 8 9 10 J Q K]
	session[:deck] = cards.product(suits)
	session[:deck].shuffle!
	session[:player_cards] = []
	session[:dealer_cards] = []
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop
	
	erb :game
end