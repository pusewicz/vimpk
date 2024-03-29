# VimPK

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/vimpk`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

Install the gem by executing:

    $ gem install vimpk

## Usage

To use the gem, you can run the following command:

    $ vimpk

#### Install a plugin

    # Will install to the default `plugins` pack directory under `start`
    $ vimpk install dense-analysis/ale
      Installed dense-analysis/ale to /Users/johndoe/.vim/pack/plugins/start/ale. Took 0.767983 seconds.

    # Will install to the `colors` pack directory under `opt`
    $ vimpk install sainnhe/sonokai --pack colors --opt
      Installed sainnhe/sonokai to /Users/johndoe/.vim/pack/colors/opt/sonokai. Took 0.844782 seconds.

#### List installed plugins

    $ vimpk list
    /Users/johndoe/.vim/pack/colors/opt/sonokai
    /Users/johndoe/.vim/pack/plugins/start/ale

    # List only opt packages
    $ vimpk list --opt
    /Users/johndoe/.vim/pack/colors/opt/sonokai

    # List only plugins
    $ vimpk list --pack plugins
    /Users/johndoe/.vim/pack/plugins/start/ale

#### Move a plugin

    # Will move to the `linting` pack directory under `start`
    $ vimpk move ale --pack linting
      Moved ale to /Users/johndoe/.vim/pack/linting/start/ale.

    # Will move to `opt`
    $ vimpk move ale --opt
      Moved ale to /Users/johndoe/.vim/pack/plugins/opt/ale.

    # Will move to `start`
    $ vimpk move ale --start
      Moved ale to /Users/johndoe/.vim/pack/plugins/start/ale.

#### Update all plugins

    $ vimpk update

#### Remove a plugin

    $ vimpk remove ale

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pusewicz/vimpk. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/pusewicz/vimpk/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Vimpk project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/pusewicz/vimpk/blob/main/CODE_OF_CONDUCT.md).
