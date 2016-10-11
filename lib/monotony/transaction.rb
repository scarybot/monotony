module Monotony
	# Holds details of a transfer of funds from one entity to another.
	class Transaction
		attr_accessor :from, :to, :amount, :reason, :is_simulation
		attr_reader :reversed, :completed
		@@all = []

		def initialize(opts)
			opts = {
				reason: nil,
				is_simulation: false
			}.merge(opts)

			if opts[:from].respond_to? :account
				@from = opts[:from].account
			else
				@from = opts[:from]
			end

			if opts[:to].respond_to? :account
				@to = opts[:to].account
			else
				@to = opts[:to]
			end

			@amount = opts[:amount]
			@reason = opts[:reason]
			@reversed = false
			@is_simulation = @to.owner.respond_to?(:is_simulation) | @from.owner.respond_to?(:is_simuation)

			@@all << self
			complete unless @is_simulation
			self
		end

		def self.all
			@@all
		end

		# Complete the transaction if possible, otherwise proceed with liquidating assets if required.
		# @return [Boolean] whether or not the transaction was completed in full.
		def complete
			@from.short_of_cash(@amount) if @from.balance < @amount
			amount_to_pay = ( @from.balance >= @amount ? @amount : @from.balance )

			@to.receive(amount_to_pay)
			@from.deduct(amount_to_pay)
			paying_to = @to.owner.name

			if amount_to_pay < amount
				@from.owner.game.log '[%s] Unable to pay £%d to %s%s! Paid £%d instead' % [ @from.owner.name, amount, paying_to, ( @reason ? ' for %s' % @reason : '' ), amount_to_pay ]
				@from.owner.bankrupt!(@to.owner) if @from.owner.respond_to? :bankrupt!
				false
			else
				@from.owner.game.log '[%s] Paid £%d to %s%s (balance: £%d)' % [ @from.owner.name, amount, paying_to, ( @reason ? ' for %s' % @reason : '' ), @from.balance ]
				true
			end

			@completed = true
		end

		# Reverse the transaction.
		# @return [void]
		def reverse
			@to.deduct(amount)
			@from.receive(amount)
			@reversed = true
		end
	end
end