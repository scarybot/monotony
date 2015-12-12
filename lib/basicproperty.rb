require 'monopoly_engine/square'
require 'monopoly_engine/purchasable'

module MonopolyEngine
	class BasicProperty < PurchasableProperty
		attr_accessor :house_cost, :hotel_cost, :set, :num_houses, :num_hotels, :rent
		def initialize(opts)
			super
			@rent = opts[:rent]
			@house_cost = opts[:house_cost]
			@hotel_cost = opts[:hotel_cost]
			@set = opts[:set]
			@num_houses = 0
			@num_hotels = 0
			@action = Proc.new do |game, owner, player, property|
				if owner
					if set_owned?
						rent_to_pay = (property.num_hotels  == 1 ? property.rent[5] : ( property.num_houses == 0 ? (@rent[0] * 2) :  property.rent[property.num_houses] ) )
					else
						rent_to_pay = property.rent[0]
					end
					if owner != player
						if not owner.is_out? and not is_mortgaged?
							puts '[%s] Due to pay £%d rent to %s for landing on %s with %s' % [ player.name, rent_to_pay, owner.name, property.name, ( property.num_hotels == 1 ? 'a hotel' : '%d houses' % property.num_houses) ]
							player.pay(owner, rent_to_pay)
						end
					end
				else
					player.behaviour[:purchase_possible].call(game, player, self) if player.currency >= cost
				end
			end
		end
		def mortgage
			super
			properties_in_set(@owner.game).each do |other|
				other.sell_hotel if @num_hotels > 0
				other.sell_houses if @num_houses > 0
			end
		end
		def add_houses(number)
			housing_value = @house_cost * number
			if @owner.game.num_houses >= number
				if (@num_houses + number) > 4
					puts '[%s] Cannot place more than 4 houses on %s' % [ @owner.name, @name ]
				else
					if @owner.currency < housing_value
						puts '[%s] Unable to buy %d houses! (short of cash by £%d)' % [ @owner.name, number, (housing_value - @owner.currency) ]
						false
					else
						@owner.currency = @owner.currency - housing_value
						@owner.game.num_houses = @owner.game.num_houses - number
						@num_houses = @num_houses + number
						puts '[%s] Purchased %d houses on %s for £%d (new balance: £%d)' % [ @owner.name, number, @name, housing_value, @owner.currency ]
						true
					end
				end
			else
				puts '[%s] Not enough houses left to purchase %d more for %s' % [ @owner.name, number, @name ]
			end
			self
		end
		def sell_houses(number)
			housing_value = (@house_cost / 2) * number
			if number > @num_houses
				puts "[%s] Can't sell %d houses on %s, as there are only %d" % [ @owner.name, number, @name, @num_houses ]
				false
			else
				@num_houses = @num_houses - number
				@owner.game.num_houses = @owner.game.num_houses + number
				@owner.currency = @owner.currency + housing_value
				puts '[%s] Sold %d houses on %s for £%d (%d remaining)' % [ @owner.name, number, @name, housing_value, @num_houses ]
			end
			self
		end
		def add_hotel
			if @num_houses == 4
				if @owner.game.num_houses > 0
					if @owner.currency < @hotel_cost
						puts '[%s] Unable to buy a hotel! (short of cash by £%d)' % [ @owner.name, (@hotel_cost - @owner.currency) ]
						false
					else
						@owner.currency = @owner.currency - @hotel_cost
						@num_houses, @num_hotels = 0, 1
						@owner.game.num_houses = @owner.game.num_houses + 4
						@owner.game.num_hotels = @owner.game.num_hotels - 1
						puts '[%s] Purchased a hotel on %s for £%d (new balance: £%d)' % [ @owner.name, @name, @hotel_cost, @owner.currency ]
						true
					end			
				else
					puts '[%s] Not enough hotels left to purchase one for %s' % [ @owner.name, @name ]
				end
			end
			self
		end
		def sell_hotel
			if @num_hotels < 1
				puts "[%s] Can't sell hotel on %s, as there isn't one!" % [ @owner.name, @name ]
			else
			 	housing_value = (@hotel_cost / 2) 
				@num_hotels = 0
				@owner.game.num_hotels = @owner.game.num_hotels + 1
				@owner.currency = @owner.currency + housing_value
				puts '[%s] Sold hotel on %s for £%d' % [ @owner.name, @name, housing_value ]
				case @owner.game.num_houses
				when 1..3
					sell_houses(4 - @owner.game.num_houses)
					puts '[%s] Devolved %s to %d houses as 4 were not available' % [ @owner.name, @name, @num_houses ]
				when 0
					sell_houses(4)
					puts '[%s] Devolved to undeveloped site as no houses were available' % [ @owner.name, @name, @num_houses ]
				else
					@owner.game.num_houses = @owner.game.num_houses - 4
					@num_houses = 4
					puts '[%s] Devolved %s to %d houses' % [ @owner.name, @name, @num_houses ]
				end
			end
			self
		end
		def display_house_ascii
			house_array = []
			house_string = ''

			if @num_hotels == 1
				house_string << '   '.colorize(:background => :light_black) + '     '.colorize(:background => :red) + '   '.colorize(:background => :light_black)
			else
				until house_array.length == @num_houses
					house_array << '  '.colorize(:background => :green) 
				end
				until house_array.length == 4
					house_array << '  '.colorize(:background => :light_black)
				end

				house_string = house_array.join(' '.colorize(:background => :light_black))
			end
			house_string + ' '.colorize(:color => :default)
		end
	end
end