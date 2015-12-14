#!/usr/bin/ruby

require 'pp'
require 'pry'
require 'colorize'

require 'monopoly_engine/basicproperty'
require 'monopoly_engine/chance'
require 'monopoly_engine/communitychest'
require 'monopoly_engine/game'
require 'monopoly_engine/player'
require 'monopoly_engine/purchasable'
require 'monopoly_engine/square'
require 'monopoly_engine/station'
require 'monopoly_engine/utility'
require 'monopoly_engine/variants'
require 'monopoly_engine/behaviour'

module MonopolyEngine
  # Say hi to the world!
  #
  # Example:
  #   >> Hola.hi("spanish")
  #   => hola mundo
  #
  # Arguments:
  #   language: (String)
	# behaviour = 

	# monopoly_players = [
	#  	Player.new( name: 'James', behaviour: behaviour ),
	#  	Player.new( name: 'Jody',  behaviour: behaviour ),
	#  	Player.new( name: 'Ryan',  behaviour: behaviour ),
	#  	Player.new( name: 'Tine',  behaviour: behaviour )
	# ]

	# monopoly = Game.new(
	# 	board: monopoly_board,
	# 	chance: chance,
	# 	community_chest: community_chest,
	# 	num_dice: 2,
	# 	die_size: 6,
	# 	starting_currency: 1500,
	# 	bank_balance: 12755,
	# 	num_hotels: 12,
	# 	num_houses: 48,
	# 	go_amount: 200,
	# 	max_turns_in_jail: 3,
	# 	players: monopoly_players
	# )
end

# Good place to break, for tweaking before starting the game
# binding.pry

# monopoly.play(ARGV[0])
