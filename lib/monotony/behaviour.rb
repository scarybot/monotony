module Monotony
	# Conains predefined behaviours
	class DefaultBehaviour
		DEFAULT = {
			purchase_possible: Proc.new { |game, player, property| 
				# If the next turn could land us somewhere more expensive than we can afford, purchase should be less likely
				if player.exposure.max > (player.balance - property.value)
					risk_factor = 0.75
				else
					risk_factor = 1
				end

				if player.properties.collect{ |p| p.set }.include? property.set
					# Will definitely buy if player already owns one or more of this set
					property.sell_to(player)
				elsif game.players.collect { |p| p.properties.collect { |p| p.set } }.flatten.include? property.set
					# Less likely to buy if another player already owns one of the set
					property.sell_to(player) if (Random.rand(0..100) * risk_factor) >= 50
				else
					# Will probably buy if nobody has bought any of this set yet
					property.sell_to(player) if (Random.rand(0..100) * risk_factor) >= 75
				end
			},
			unmortgage_possible: Proc.new { |game, player, property|
				# Only bother unmortgaging something if I have the rest of the set, or it's less than 15% of my cash
				if player.sets_owned.include? property.set
					# Always if it completes a set
					property.unmortgage
				elsif ( property.cost.to_f / player.balance.to_f * 100.0 ) < 15.0
					# Only if we're not about to be stung for landing somewhere expensive
					if player.exposure.max > (player.balance - property.cost)
						property.unmortgage
					end
				end
			},
			houses_available: Proc.new { |game, player, property|
				# Buy houses when possible, but don't spend more than 40% of my money on them in any one turn
				can_afford = ( ( player.balance * 0.4 ) / property.house_cost ).floor
				max_available = 4 - property.num_houses
				to_buy = [ can_afford, max_available ].min

				# Think twice about buying a house if we're likely to land somewhere expensive next turn
				if player.exposure.max > (player.balance - property.house_cost)
					risk_factor = 0.6
				else
					risk_factor = 1
				end

				if (Random.rand(0..100) * risk_factor) >= 50
					property.add_houses(to_buy) if to_buy > 0 unless game.active_players == 1
				end
			},
			hotel_available: Proc.new { |game, player, property|
				# Buy a hotel, unless it's more than two thirds of my current balance.
				property.add_hotel unless ( property.hotel_cost.to_f / player.balance.to_f * 100.0) > 66.6
			},
			out_of_cash: Proc.new { |game, player, amount|
				portfolio = player.properties.sort_by { |p| p.mortgage_value }
				while player.balance < amount do
					if portfolio.length > 0
						property = portfolio.shift
						if property.is_a? BasicProperty
							if property.num_hotels == 1
								property = property.sell_hotel
							end
							break if player.balance >= amount

							while property.num_houses > 0
								property = property.sell_houses(1)
								break if player.balance >= amount
							end
							break if player.balance >= amount

							property = property.mortgage
						end
					else
						break
					end
				end
			},
			use_jail_card: Proc.new { |game, player|
				# Unless less than 50% of active sets are mine, get out of jail with a card when possible
				player.use_jail_card! unless ( player.sets_owned.count.to_f / game.all_sets_owned.count.to_f * 100.0 ) < 50
			},
			trade_possible: Proc.new { |game, player|
				game.log '[%s] Considering possible trades' % player.name
			    invested_colours = player.properties.collect(&:set).uniq
			    player.opponents.each do |opponent|
			    	opponent.properties.select { |r| invested_colours.include? r.set }.each do |desirable_property|
			    		factors = {}
			    		# e.g. 66% chance of buying if one property is owned, 99% chance of buying if two are
			    		factors[:number_owned] = ( desirable_property.number_of_set_owned.to_f + 1.0 ) / desirable_property.number_in_set(game).to_f
			    		# More likely to trade if cash rich
						factors[:currency] = player.balance.to_f / 1000.to_f
			    		# More likely to trade if close to GO
			    		factors[:proximity_to_go] = 1 - ( player.distance_to_go.to_f / game.board.length.to_f )

			    		# We use these factors to work out how much to offer relative to how much we have
			    		offer_amount = player.balance * factors.values.inject(&:*)
			    		if offer_amount > desirable_property.cost and player.balance >= offer_amount
							game.log '[%s] Placing offer of £%d on %s (owned by %s) [%f]' % [ player.name, offer_amount, desirable_property.name, desirable_property.owner.name, factors.values.inject(&:*) * 100 ]

				    		desirable_property.place_offer(player, offer_amount)
				    	end
			    	end
			    end
			},
			trade_proposed: Proc.new { |game, player, proposer, property, amount|
				factors = {}
				# More likely to accept a trade the longer the game has been going on for (definitely at 100 turns)
				factors[:longevity] = ( [0, game.turn, 100].sort[1].to_f / 100.0 ).to_f
				# More likely to accept a trade if it is far over the list price
				factors[:value_added] = 1 - ( property.cost.to_f / amount.to_f )
				# More likely to accept a trade if low on cash
				factors[:currency] = 1 - ( player.balance.to_f / 1000.to_f )

				# Random element
				factors[:random] = Random.rand(1..100)
				game.log '[%s] Considering offer of £%d for %s (from %s) [%f]' % [ player.name, amount, property.name, proposer.name, ( factors.values.collect{ |f| ( 100 / factors.count ) * f }.inject(:+) / 100 ) ]
				property.sell_to(proposer, amount) if Random.rand(1..100) > ( factors.values.collect{ |f| ( 100 / factors.count ) * f }.inject(:+) / 100 )
			}
		}

		SIMULATION = {
			purchase_possible: Proc.new { |game, player, property| },
			unmortgage_possible: Proc.new { |game, player, property| },
			houses_available: Proc.new { |game, player, property| },
			hotel_available: Proc.new { |game, player, property| },
			money_trouble: Proc.new { |game, player, amount| },
			use_jail_card: Proc.new { |game, player| },
			trade_possible: Proc.new { |game, player| },
			trade_proposed: Proc.new { |game, player, proposer, property, amount| }
		}
	end
end
