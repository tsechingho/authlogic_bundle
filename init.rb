if config.respond_to?(:gems)
  config.gem 'authlogic', :lib => 'authlogic', :version => '>=1.4.1'
else
  begin
    require 'authlogic'
  rescue LoadError
    begin
      gem 'authlogic', '>=1.4.1'
    rescue Gem::LoadError
      puts "Please install the authlogic gem"
    end
  end
end