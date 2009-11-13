module AuthlogicBundle
  module Maintenance
    mattr_accessor :speak

    def create_user_by_login(login, roles=[], attrs={})
      login = attrs[:login] || login.tr(' \'"','').ljust(4,'_') # login.size > 3 ; Authlogic::Regex.login
      user = ::User.find_by_login(login)
      unless user
        puts "Creating user '#{login}' ..." if speak
        user = ::User.new
        user.signup!({:login => login, :email => attrs[:email] || "#{login.downcase}@example.com"})
        user.activate!({:login => login, :password => login, :password_confirmation => login})
        roles.each { |role| user.assign_role(role) }
        puts "user '#{login}' created. login/password is #{login}/#{login}." if user.valid? && speak
      else
        puts "user '#{login}' already exists." if speak
      end
      user
    end

    def delete_user_by_login(login)
      if user = ::User.find_by_login(login)
        user.delete
        puts "user '#{login}' deleted." if speak
      end
    end

    def create_roles_from_rule_file(file=nil, skips=[:guest])
      file ||= "#{RAILS_ROOT}/config/authorization_rules.rb"
      puts "Reading #{file} ..." if speak
      reader = ::Authorization::Reader::DSLReader.load file
      reader.auth_rules_reader.roles.each do |role|
        next if skips.include? role
        ::Role.find_or_create_by_name(
          :name => role.to_s,
          :title => reader.auth_rules_reader.role_titles[role],
          :description => reader.auth_rules_reader.role_descriptions[role]
        )
      end
      puts "Roles [ #{::Role.all.map(&:title).join(', ')} ] created." if speak
    end
  end
end