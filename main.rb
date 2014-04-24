require 'rubygems'
require 'sinatra'

set :sessions, true

helpers do

	def calculate_total(cards)
		arr = cards.map{|e| e[0]}

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
	redirect '/bet'
end

get '/bet' do 
	erb :bet
end

post '/bet' do 
	session[:bet] = params[:bet]
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

	if calculate_total(session[:player_cards]) == 21
		@yay = "You got 21. You win!"
	end
	
	erb :game
end

post '/hit' do 
	session[:player_cards] << session[:deck].pop

	if calculate_total(session[:player_cards]) > 21
		@error = 'You busted! Game over.'
	elsif calculate_total(session[:player_cards]) == 21
		@yay = "You got 21. You win!"
	end

	erb :game
end

post '/stay' do 
	while calculate_total(session[:dealer_cards]) < 17
		session[:dealer_cards] << session[:deck].pop
		calculate_total(session[:dealer_cards])
	end

	if calculate_total(session[:dealer_cards]) == 21
		@error = "The dealer has 21. You lost!"
	elsif calculate_total(session[:dealer_cards]) < 21
		if calculate_total(session[:player_cards]) > calculate_total(session[:dealer_cards])
			@yay = "The dealer has " + calculate_total(session[:dealer_cards]).to_s + ". You beat the dealer! You win."
		elsif calculate_total(session[:player_cards]) < calculate_total(session[:dealer_cards])
			@error = "The dealer has " + calculate_total(session[:dealer_cards]).to_s + ". You lost!"
		else
			@tie = "You tied the dealer."
		end
	end
			

	erb :game
end




