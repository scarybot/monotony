module Monotony
	class Account
		attr_accessor :balance, :name, :owner
		@@all = []

		def initialize(opts)
			opts = {
				balance: 0,
				owner: nil,
				name: nil
			}.merge(opts)

			@owner = opts[:owner]
			@balance = opts[:balance]
			@@all << self
		end

		def self.all
			@@all
		end

		def receive(amount)
			@balance = @balance + amount
		end

		def deduct(amount)
			@balance = @balance - amount
		end

		def debits
			Transactions.collect { |t| t.from == self }
		end

		def credits
			Transactions.collect { |t| t.to == self }
		end

		def transactions
			Transactions.collect { |t| t.to == self or t.from == self }
		end

		def short_of_cash(amount)
			@owner.short_of_cash(amount) if @owner.respond_to? :short_of_cash
		end
	end
end