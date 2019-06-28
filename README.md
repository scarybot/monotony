# Monotony

This gem is an engine to simulate games of Monopoly.

[![Gem Version](https://badge.fury.io/rb/monotony.svg)](https://badge.fury.io/rb/monotony)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'monotony'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install monotony

## Usage

To play a quick game of Monopoly, with classic board layout and four randomly generated players:

```ruby

    game = Monotony::Game.new({})
    game.play

    # See the results of the game
    game.summary

```

You can step through the game a few turns at a time, and use the ```summary``` method to view an ASCII representation of the state of the game.

```ruby
    game.play(10).summary
```

```ruby
    monopoly_players = [
        Player.new( name: 'James' ),
        Player.new( name: 'Jody' ),
        Player.new( name: 'Ryan' ),
        # This player is using a custom behaviour hash. See docs for more details.
        Player.new( name: 'Tine',  behaviour: behaviour ) 
    ]

    # Board layout and chance/community chest cards can be defined here; see docs for more details.
    monopoly = Monotony::Game.new(
        board: monopoly_board,
        chance: chance,
        community_chest: community_chest,
        num_dice: 2,
        die_size: 6,
        starting_currency: 1500,
        bank_balance: 12755,
        num_hotels: 12,
        num_houses: 48,
        go_amount: 200,
        max_turns_in_jail: 3,
        players: monopoly_players
    )
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/scarybot/monotony.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

