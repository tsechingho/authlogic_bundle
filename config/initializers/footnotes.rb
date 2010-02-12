if Rails.env == 'development' && defined?(Footnotes)
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
