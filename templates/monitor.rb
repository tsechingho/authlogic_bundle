##############################
# Monitor
##############################
gem 'josevalim-rails-footnotes', :lib => 'rails-footnotes', :version => '3.4.1',
  :source => 'http://gems.github.com', :env => 'development'

rake 'gems:install', :sudo => true, :env => 'development'

initializer 'footnotes.rb', <<-CODE
if ENV['RAILS_ENV'] == 'development'
  # NOT Textmate editor:
  # if defined?(Footnotes)
  #  Footnotes::Filter.prefix = 'txmt://open?url=file://%s&line=%d&column=%d'
  # end

  # Show notes
  Footnotes::Filter.notes = [:session, :cookies, :params, :filters, :routes, :env, :queries, :log, :general]
  # Edit notes
  Footnotes::Filter.notes << [:layout, :stylesheets, :javascripts]
  # Do not include these filters since footnote does not works with rails engine
  # Footnotes::Filter.notes << [:controller, :view]
  Footnotes::Filter.multiple_notes = true
  # Footnotes::Filter.no_style = true
end
CODE


if git?
  git :submodule => "init"
  git :submodule => "update"
  git :add => "config"
  git :commit => "-m 'setup monitor suite'"
end