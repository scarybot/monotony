require 'monopoly_engine/square'

module MonopolyEngine
	class PurchasableProperty < Square
		attr_accessor :value, :cost, :is_mortgaged, :owner, :mortgage_value
		def initialize(opts)
			super
			@game = nil
			@is_mortgaged = false
			@value = opts[:value]
			@mortgage_value = opts[:mortgage_value]
		end
		def sell_to(player, amount = cost)
			if player.currency < amount then
				puts '[%s] Unable to buy %s! (short of cash by £%d)' % [ player.name, @name, ( amount - player.currency ) ]
				false
			else
				player.currency = player.currency - amount.to_i

				if @owner
					@owner.currency = @owner.currency + amount
					puts '[%s] Sold %s%s to %s for £%d (new balance: £%d)' % [ @owner.name, @name, (is_mortgaged? ? ' (mortgaged)' : ''), player.name, amount, @owner.currency ]
					@owner.properties.delete self
				else
					puts '[%s] Purchased %s%s for £%d (new balance: £%d)' % [ player.name, @name, (is_mortgaged? ? ' (mortgaged)' : ''), amount, player.currency ]
				end

				player.properties << self
				@owner = player
			end
		end
		def number_in_set(game = @owner.game)
			properties_in_set(game).count
		end
		def properties_in_set(game = @owner.game)
			game.board.select { |p| p.is_a? self.class }.select { |p| p.set == @set }
		end
		def cost
			if is_mortgaged?
				@value * 1.1
			else
				@value
			end
		end

		def number_of_set_owned
			if @owner
				@owner.properties.select { |p| p.is_a? self.class }.select { |p| p.set == @set }.count
			end
		end
		def place_offer(proposer, amount)
			@owner.behaviour[:trade_proposed].call(@owner.game, @owner, proposer, self, amount) if proposer.currency >= amount
		end
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
		def give_to(player)
			puts '[%s] Gave %s to %s' % [ @owner.name, @name, player.name ]
			@owner.properties.delete self
			@owner = player
			player.properties << self
		end
		def mortgage
			unless is_mortgaged?
				puts '[%s] Mortgaged %s for £%d' % [ @owner.name, @name, @mortgage_value ]
				@is_mortgaged = true
				@owner.currency = @owner.currency + @mortgage_value
				@mortgage_value
			end
			self
		end
		def unmortgage
			if is_mortgaged?
				if @owner.currency > cost
					puts '[%s] Unmortgaged %s for £%d' % [ @owner.name, @name, cost ]
					@owner.currency = @owner.currency - cost
					@is_mortgaged = false
				else
					puts '[%s] Unable to unmortgage %s (not enough funds)' % [ @owner.name, @name ]
				end
			else
				puts '[%] Tried to unmortgage a non-mortgaged property (%s)' % [ @owner.name, @name ]
			end
			self
		end
		def is_mortgaged?
			@is_mortgaged
		end
	end
end