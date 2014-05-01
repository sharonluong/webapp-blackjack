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

	def card_image(card)
		value = card[0]
			if ['A', 'J', 'Q', 'K'].include?(value)
				value = case card[0]
					when 'A' then 'ace'
					when 'K' then 'king'
					when 'Q' then 'queen'
					when 'J' then 'jack'
				end
			end

		suit = card[1]

		"<img src='/images/cards/#{suit}_#{value}.jpg'>"
	end

	def winner(msg)
		session[:pot] += session[:player_bet].to_i
		@show_new_game = true
		@show_decision = false
		@show_dealer_cards = true
		@not_show_first = false
		@winner = "#{msg} #{session[:player_name]} wins and now has a total of $#{session[:pot].to_s}."

	end

	def loser(msg)
		session[:pot] -= session[:player_bet].to_i
		@show_decision = false
		@show_dealer_cards = true
		@not_show_first = false
		@loser = " #{msg} #{session[:player_name]} loses and now has a total of $#{session[:pot].to_s}."
		if session[:pot] == 0
			@show_new_game = false
		else
			@show_new_game = true
		end
	end

end

before do 
	@show_decision = true
	@show_dealer_cards = false
	@not_show_first = true
	@show_new_game = false
end

get '/' do
	redirect '/new_game'
end

get '/new_game' do
	erb :new_game
end

post '/new_game' do
	session[:player_name] = params[:player_name]
	if params[:player_name].empty?
		@error = "Please put in a player name."
		halt erb(:new_game)
	else
		session[:pot] = 500
		redirect '/bet'
	end
	
end

get '/bet' do 
	erb :bet
end

post '/bet' do 
	if params[:player_bet].nil? || params[:player_bet].to_i == 0
		@error = "Please put in a valid bet."
		halt erb(:bet)
	elsif params[:player_bet].to_i > session[:pot]
		@error = "You cannot bet more than you have in the pot."
	else
		session[:player_bet] = params[:player_bet].to_i
		redirect '/game'
	end
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
		winner("21!")
	end
	
	erb :game
end

post '/game/player/hit' do 
	@show_dealer_cards = false
	session[:player_cards] << session[:deck].pop

	if calculate_total(session[:player_cards]) > 21
		loser("Bust!")
	elsif calculate_total(session[:player_cards]) == 21
		winner("21!")
	end

	erb :game, layout:false
end

post '/game/player/stay' do

	redirect '/game/dealer'
end

get '/game/dealer' do
	@not_show_first = false
	@show_dealer_cards = true
	calculate_total(session[:dealer_cards])

 	if calculate_total(session[:dealer_cards]) == 21
		loser("The dealer has 21.")
	elsif calculate_total(session[:dealer_cards]) > 21
		winner("Dealer busted because they had #{calculate_total(session[:dealer_cards])}.")
	elsif calculate_total(session[:dealer_cards]) >= 17
		redirect '/game/compare'
	else
		@show_dealer_hit = true
	end

	erb :game, layout:false
end

post '/game/dealer/hit' do 
	@show_decision = false
	@not_show_first = false
	@show_dealer_cards = true
	
	session[:dealer_cards] << session[:deck].pop
	calculate_total(session[:dealer_cards])


	@show_dealer_cards = true
	@show_dealer_hit = false
	
	redirect '/game/dealer'
end

get '/game/compare' do 
	@not_show_first = false
	@show_decision = false
	@show_dealer_cards = true

	if calculate_total(session[:player_cards]) > calculate_total(session[:dealer_cards])
		winner("The dealer has " + calculate_total(session[:dealer_cards]).to_s + ".")
	elsif calculate_total(session[:player_cards]) < calculate_total(session[:dealer_cards])
		loser("The dealer has " + calculate_total(session[:dealer_cards]).to_s + ".")
	else
		@tie = "You tied the dealer. Here is your bet back."
		@show_new_game = true
	end

	erb :game
end

get '/game_over' do 
	erb :game_over
end





