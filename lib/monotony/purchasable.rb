require 'monotony/square'

module Monotony
	# Represents any purchasable property tile.
	class PurchasableProperty < Square
		attr_accessor :value, :cost, :is_mortgaged, :owner, :mortgage_value
		# @param opts [Hash]
		# @option opts [Integer] :value the value of the property.
		# @option opts [Integer] :mortgage_value the mortgaged value of the property.
		# @option opts [Symbol] :set a symbol identifying this property as a member of a set of properties.
		# @option opts [String] :name the name of the property.
		def initialize(opts)
			super
			opts = {
				game: nil,
				is_mortgaged: false,
				value: 0,
				mortgage_value: 0
			}.merge(opts)

			@game = opts[:game]
			@is_mortgaged = opts[:is_mortgaged]
			@value = opts[:value].to_int
			@mortgage_value = opts[:mortgage_value].to_int
		end

		# Action to take on landing on properties of this type
		def action(**args)
			args[:player].decide(:purchase_possible, property: self) if args[:player].balance >= cost unless @owner
			super
		end

		# Called at the start of every turn
		def maintenance_actions
			if @is_mortgaged?
				unmortgage if @owner.decide(:unmortgage_possible, property: self).is_yes? and @owner.balance > @cost
			end
			super
		end

		# Transfer a property to another player, in return for currency.
		# @param player [Player] Receiving player
		# @param amount [Integer] Sale value
		def sell_to(player, amount = cost)
			amount = amount.to_int
			if player.balance < amount then
				player.game.log '[%s] Unable to buy %s! (short of cash by £%d)' % [ player.name, @name, ( amount - player.balance ) ]
				false
			else
				if @owner
					Transaction.new(to: @owner, from: player, amount: amount.to_i, reason: 'property trade')
					player.game.log '[%s] Sold %s%s to %s for £%d (new balance: £%d)' % [ @owner.name, @name, (is_mortgaged? ? ' (mortgaged)' : ''), player.name, amount, @owner.balance ]
					@owner.properties.delete self
				else
					Transaction.new(to: player.game.bank, from: player, amount: amount.to_i, reason: 'property purchase')
					player.game.log '[%s] Purchased %s%s for £%d (new balance: £%d)' % [ player.name, @name, (is_mortgaged? ? ' (mortgaged)' : ''), amount, player.balance ]
				end

				player.properties << self
				@owner = player
			end
		end

		# Returns the number of properties in the set containing self.
		# @return [Integer]
		def number_in_set(game = @owner.game)
			properties_in_set(game).count
		end

		# Returns property objects for all properties in the same set as self.
		# @return [Array<Square>]
		def properties_in_set(game = @owner.game)
			game.board.select { |p| p.is_a? self.class }.select { |p| p.set == @set }
		end

		# @return [Integer] the current cost to either purchase this property unowned, or unmortgage this property if mortgaged.
		def cost
			if is_mortgaged?
				@value * 1.1
			else
				@value
			end
		end

		# @return [Integer] the number of properties in the same set as this one which are currenly owned by players.
		def number_of_set_owned
			if @owner
				@owner.properties.select { |p| p.is_a? self.class }.select { |p| p.set == @set }.count
			end
		end

		# Offer to purchase this property from another player, thus calling the :trade_proposed behaviour of the receiving player.
		def place_offer(proposer, amount)
			if proposer.balance >= amount
				property.sell_to(proposer, amount) if @owner.decide(:trade_proposed, game: @owner.game, player: @owner, proposer: proposer, property: self, amount: amount).is_yes?
			end
		end

		# @return [Boolean] whether or not this property is part of a complete set owned by a single player.
		def set_owned?
			if @owner
				player_basic_properties = @owner.properties.select { |p| p.is_a? self.class }
				board_basic_properties = @owner.game.board.select { |p| p.is_a? self.class }
				player_properties_in_set = player_basic_properties.select { |p| p.set == @set and p.is_mortgaged? == false }
				board_properties_in_set = board_basic_properties.select { |p| p.set == @set }
				(board_properties_in_set - player_properties_in_set).empty?
			else
				false
			end
		end

		# Gives a property to another player. Available for use as part of a trading behaviour.
		def give_to(player)
			player.game.log '[%s] Gave %s to %s' % [ @owner.name, @name, player.name ]
			@owner.properties.delete self
			@owner = player
			player.properties << self
		end

		# Mortgage the property to raise cash for its owner.
		# @return [self]
		def mortgage
			unless is_mortgaged?
				@owner.game.log '[%s] Mortgaged %s for £%d' % [ @owner.name, @name, @mortgage_value ]
				@is_mortgaged = true
				Transaction.new(to: @owner, from: @owner.game.bank, amount: mortgage_value, reason: 'mortgaging %s' % @name)
				@mortgage_value
			end
			self
		end

		# Unmortgage the property.
		# @return [self]
		def unmortgage
			if is_mortgaged?
				if @owner.balance > cost
					@owner.game.log '[%s] Unmortgaged %s for £%d' % [ @owner.name, @name, cost ]
					Transaction.new(to: @owner.game.bank, from: @owner, amount: cost, reason: 'unmortgaging %s' % name)
					@is_mortgaged = false
				else
					@owner.game.log '[%s] Unable to unmortgage %s (not enough funds)' % [ @owner.name, @name ]
				end
			else
				@owner.game.log '[%] Tried to unmortgage a non-mortgaged property (%s)' % [ @owner.name, @name ]
			end
			self
		end

		# @return [Boolean] whether or not the property is currently mortgaged.
		def is_mortgaged?
			@is_mortgaged
		end
	end
end