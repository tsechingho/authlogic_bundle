submodules = []

plugins = Dir.glob('vendor/plugins/*')
for plugin in plugins
  inside(plugin) do
    if File.exist? ".git/config"
      run "git pull origin master"
      submodules << File.basename(plugin)
    end
  end
end

run "git commit -a -m 'update submodules : #{submodules.join(', ')}'"