require "declarative_authorization/maintenance"
include Authorization::Maintenance

require "authlogic_bundle/maintenance"
include AuthlogicBundle::Maintenance
AuthlogicBundle::Maintenance.speak = true

create_roles_from_rule_file

root = create_user_by_login('root', ['admin'])

without_access_control do
end
