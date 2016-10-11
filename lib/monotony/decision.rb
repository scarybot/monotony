module Monotony
	class Decision
		attr_reader :factors, :elements
		attr_accessor :outputs

		def initialize(**elements)
			@elements = elements
			@outputs = { }
			@probability = nil
			@outcome = nil

			# By default, the decision is positive
			@factors = [ 1 ]
			self
		end

		# We only want to decide once and store the result
		def outcome
			if @outcome
				@outcome
			else
				pp @factors
				@probability = @factors.inject(:*)
				@outcome = Random.rand(1..100) < (@factors.inject(:*) * 100)
			end
		end

		def yes!
			@outcome = true
		end

		def no!
			@outcome = false
		end

		def is_yes?
			outcome
		end

		def is_no?
			!outcome
		end

		def [](element)
			@elements[element]
		end
	end
end