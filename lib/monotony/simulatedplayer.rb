module Monotony
	# Represents a simulated player for the purposes of working out possible risk next turn.
	class SimulatedPlayer < Player
		attr_reader :transactions, :is_simulation
		attr_accessor :hits, :board, :name, :currency, :history, :properties, :in_game, :turns_in_jail, :behaviour, :game, :jail_free_cards, :in_jail, :account

		# @return [SimulatedPlayer] self
		# @param [Player] player Object representing player to simulate
		def initialize(player)
			@history = player.history
			@in_game = player.in_game
			@in_jail = player.in_jail
			@turns_in_jail = player.turns_in_jail
			@jail_free_cards = player.jail_free_cards
			@currency = player.balance
			@game = player.game.clone
			@name = 'sim'
			@board = @game.board
			@properties = player.properties
			@behaviour = Monotony::DefaultBehaviour::SIMULATION
			@account = player.account.clone
			@account.owner = self
			@is_simulation = true
			self
		end
	end
end