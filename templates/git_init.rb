#########################
#  SCM
#########################
git :init

file '.gitignore', <<-CODE
.DS_Store
._*
Icon?
config/database.yml
coverage.data
coverage/*
db/*.sqlite3
db/schema.rb
log/*.log
tmp/**/*
CODE

# tell git to hold empty directories
#run %{find . -type d -empty | grep -v ".git" | xargs -I xxx touch xxx/.gitignore}
run "touch log/.gitignore tmp/.gitignore vendor/.gitignore"

run "cp config/database.yml config/database.yml.example"

git :add => "."
git :commit => "-m 'initial commit'"