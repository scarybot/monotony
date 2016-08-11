require 'monotony/purchasable'
require 'colorize'

RSpec.describe Monotony::PurchasableProperty do
	describe '#initialize' do
		it "sets the name correctly" do
			expect(Monotony::PurchasableProperty.new(name: 'testname').name).to eq 'testname'
		end
		it "sets the set correctly" do
			expect(Monotony::PurchasableProperty.new(name: 'testname', set: 'testset').set).to eq 'testset'
		end
		it "sets the colour correctly" do
			expect(Monotony::PurchasableProperty.new(name: 'testname', set: 'testset', colour: 'testcolour').colour).to eq 'testcolour'
		end
		it "sets the default action to a Proc" do
			expect(Monotony::PurchasableProperty.new(name: 'testname', set: 'testset').action).to be_a Proc
		end
		it "sets the action correctly" do
			expect(Monotony::PurchasableProperty.new(name: 'testname', set: 'testset', action: Proc.new {'blahblah'}).action).to be_a Proc
			expect(Monotony::PurchasableProperty.new(name: 'testname', set: 'testset', action: Proc.new {'blahblah'}).action.call).to eq 'blahblah'
		end
	end
end