module Monotony
	class Entity
		attr_accessor :name, :history, :properties, :in_game, :behaviour, :game 
		attr_reader :account

		def initialize(opts = {})
			opts = {
				behaviour: Monotony::DefaultBehaviour::DEFAULT,
				balance: 0,
				game: nil
			}.merge(opts)

			@behaviour = opts[:behaviour]
			@account = Account.new(owner: self, balance: opts[:balance].to_int)
			@game = opts[:game]
			@name = opts[:name].to_s
			@in_game = true
			@board = []
			@properties = []
			@board = []
			@properties = []
			@history = []
			self
		end

		def balance
			@account.balance
		end

		# Called when an entity is unable to pay a debt. Calls the 'money_trouble' behaviour.
		# @param [Integer] amount amount of currency to be raised.
		# @return [Boolean] whether or not the player was able to raise the amount required.
		def short_of_cash(amount)
			amount = amount.to_int

			@game.log '[%s] Not enough cash to pay £%d... (balance: £%d)' % [ @name, (amount - @account.balance), @account.balance ]
			@behaviour[:out_of_cash].call(game, self, amount)
			@account.balance > amount
		end
	end
end