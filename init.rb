if config.respond_to?(:gems)
  config.gem 'authlogic', :lib => 'authlogic', :version => '>=2.1.1'
else
  begin
    require 'authlogic'
  rescue LoadError
    begin
      gem 'authlogic', '>=2.1.1'
    rescue Gem::LoadError
      puts "Please install the authlogic gem"
    end
  end
end

require "authlogic_bundle"