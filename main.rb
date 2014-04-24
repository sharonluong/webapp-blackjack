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

	def cash_total(bet)
		cash_amount = 500
		if @error
			cash_amount -= bet
		elsif @yay
			cash_amount += bet
		end
	end

end

before do 
	@show_decision = true
	@show_dealer_cards = false
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

#get '/bet' do 
	#erb :bet
#end

#post '/bet' do 
	#session[:player_bet] = params[:player_bet]
	#redirect '/game'
#end

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

post '/game/player/hit' do 
	session[:player_cards] << session[:deck].pop

	if calculate_total(session[:player_cards]) > 21
		@error = 'You busted! Game over.'
		@show_decision = false
	elsif calculate_total(session[:player_cards]) == 21
		@yay = "You got 21. You win!"
		@show_decision = false
	end

	erb :game
end

post '/game/player/stay' do 
	@show_decision = false
	@show_dealer_cards = true
	erb :game
end

post '/game/dealer/hit' do 
	@show_decision = false
	@show_dealer_cards = false


	while calculate_total(session[:dealer_cards]) < 17
		@show_dealer_cards = true
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




