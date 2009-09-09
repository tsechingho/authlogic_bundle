def create_user_by_login(login, roles=[])
  unless User.find_by_login(login)
    puts "Creating user '#{login}' ..."
    login = login.tr(' \'"','').ljust(4,'_') # login.size > 3
    u = User.new
    u.signup! :login => login, :email => "#{login}@example.com"
    u.activate! :password => login, :password_confirmation => login
    roles.each { |r| u.assign_role(r) }
    puts "user '#{login}' created. login/password is #{login}/#{login}."
  else
    puts "user '#{login}' already exists."
  end
end

def delete_user_by_login(login)
  if u = User.find_by_login(login)
    u.delete
    puts "user '#{login}' deleted."
  end
end

reader = Authorization::Reader::DSLReader.load "#{RAILS_ROOT}/config/authorization_rules.rb"
reader.auth_rules_reader.roles.each do |role|
  next if role == :guest
  Role.find_or_create_by_name(:name => role.to_s, :title => reader.auth_rules_reader.role_titles[role], :description => reader.auth_rules_reader.role_descriptions[role])
end
puts "Roles #{Role.all.map(&:title).join(', ')} created."

create_user_by_login("root", ["admin"])
