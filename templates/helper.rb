def git?
  ENV['SCM'] ||= 'git' if ENV['SCM'].blank? && yes?('Use git as scm? (y/n)')
  ENV['SCM'] == 'git'
end

def sudo?
  ENV['SUDO'] = yes?('Install gems as root? (y/n)') ? 'yes' : 'no' if ENV['SUDO'].blank?
  ENV['SUDO'] == 'yes'
end

def edge_rails?
  ENV['EDGE_RAILS'] ||= ask("Absolute path for edge rails symbol link [Press enter to skip]:")
  !ENV['EDGE_RAILS'].blank?
end

def file_append(file, data)
  log 'file_append', file
  append_file(file, data)
end

def file_inject(file_name, sentinel, string, before_after=:after)
  log 'file_inject', file_name
  gsub_file file_name, /(#{Regexp.escape(sentinel)})/mi do |match|
    if :after == before_after
      "#{match}\n#{string}"
    else
      "#{string}\n#{match}"
    end
  end
end
