def git?
  ENV['SCM'] == 'git'
end

def file_append(file, data)
  File.open(file, 'a') { |f| f.write(data) }
end

def file_inject(file_name, sentinel, string, before_after=:after)
  gsub_file file_name, /(#{Regexp.escape(sentinel)})/mi do |match|
    if :after == before_after
      "#{match}\n#{string}"
    else
      "#{string}\n#{match}"
    end
  end
end