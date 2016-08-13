module Monotony

	# Represents any landable square on the board.
	class Square
		attr_accessor :action, :name, :owner, :colour, :display_name, :display_class, :is_simulation

		# @return [Symbol] Returns the name of the set containing this property.
		attr_accessor :set

		# @param [Hash] opts
		# @option opts [Symbol] :set a symbol identifying this property as a member of a set of properties.
		# @option opts [String] :name the name of the property.
		# @option opts [String] :display_name the displayed name of the property.
		# @option opts [Proc] :action a procedure to run when a player lands on this square.
		# @option opts [Symbol] :colour the colour to use when rendering this square on a GUI.
		def initialize(opts)
			opts = {
				owner: nil,
				set: nil,
				action: Proc.new { |game, owner, player, property| }
			}.merge(opts)

			@owner = nil
			@set = opts[:set]
			@name = opts[:name]
			@display_name = opts[:display_name] || opts[:name]
			@display_class = opts[:display_class] || 'square'
			@action = opts[:action]
			@colour = opts[:colour] || ( String.colors.include? opts[:set] ? opts[:set] : :light_black )
			@is_simulation = false
		end
		def is_simulation=(simulating)
			@is_simulation = simulating
			self
		end
		def simulate
			simulation = self.clone
			simulation.is_simulation = true
			simulation
		end
	end
end