module Monotony
	# Represents an entity in the game, holding an account and properties.
	class Entity
		attr_accessor :name, :history, :properties, :in_game, :behaviour, :game 
		attr_reader :account

		# @param [Hash] opts
		# @option opts [Game] :game The game object to which this entity belongs.
		# @option opts [Integer] :balance The opening balance of this entity's account.
		# @option opts [Hash] :behaviour Behaviour has describing this player's reaction to certain in-game situations. See Behaviour class.
		# @option opts [String] :name The name of the entity.
		# @return [Entity] self
		def initialize(opts = {})
			opts = {
				balance: 0,
				game: nil,
				behaviour: {}
			}.merge(opts)

			@account = Account.new(owner: self, balance: opts[:balance].to_int)
			@game = opts[:game]
			@name = opts[:name].to_s
			@behaviour = opts[:behaviour]
			@in_game = true
			@board = []
			@properties = []
			@board = []
			@properties = []
			@history = []
			self
		end

		# @return [Integer] the balance of the account
		def balance
			@account.balance
		end

		# Called when an entity is unable to pay a debt. Calls the 'money_trouble' behaviour.
		# @param [Integer] amount amount of currency to be raised.
		# @return [Boolean] whether or not the player was able to raise the amount required.
		def short_of_cash(amount)
			amount = amount.to_int
			@game.log '[%s] Unable to pay debt (short by £%d)... (balance: £%d)' % [ @name, (amount - @account.balance), @account.balance ]
		end
	end
end