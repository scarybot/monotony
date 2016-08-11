module Monotony
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
			@is_simulation = opts[:to].respond_to?(:is_simulation) | opts[:from].respond_to?(:is_simuation)

			@@all << self
			complete unless @is_simulation
			self
		end

		def self.all
			@@all
		end

		def complete
			@from.short_of_cash(@amount) if @from.balance < @amount
			amount_to_pay = ( @from.balance >= @amount ? @amount : @from.balance )

			@to.receive(amount)
			@from.deduct(amount)
			paying_to = @to.owner.name

			if amount_to_pay < amount then		
				@from.owner.game.log '[%s] Unable to pay £%d to %s%s! Paid £%d instead' % [ @from.name, amount, paying_to, ( description ? ' for %s' % description : '' ), amount_to_pay ]
				@from.owner.bankrupt!(@to) if @from.respond_to? :bankrupt!
				false
			else
				@from.owner.game.log '[%s] Paid £%d to %s%s (balance: £%d)' % [ @from.owner.name, amount, paying_to, ( @reason ? ' for %s' % @reason : '' ), @from.balance ]
				true
			end

			@completed = true
		end

		# Not sure if this will actually be useful
		def reverse
			@to.deduct(amount)
			@from.receive(amount)
			@reversed = true
		end
	end
end