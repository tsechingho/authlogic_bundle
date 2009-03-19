submodules = []

plugins = Dir.glob('vendor/plugins/*')
for plugin in plugins
  if File.exist? ".git/config"
    inside(plugin) do
      run "git pull origin master"
      submodules << File.basename(plugin)
    end
    git :add => plugin
  end
end

git :commit => "-m 'update submodules : #{submodules.join(', ')}'"