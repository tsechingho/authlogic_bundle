submodules = []

plugins = Dir.glob('vendor/plugins/*')
for plugin in plugins
  inside(plugin) do
    if File.exist? ".git/config"
      run "git pull origin master"
      submodules << File.basename(plugin)
    end
  end
  git :add => plugin
end

git :commit => "-m 'update submodules : #{submodules.join(', ')}'"