include Rails::Sh

Command.define 'help' do
  Rails::Sh.execute_rails_command('--help')
  puts <<HELP

\e[36mThe rails-sh commands are:
 help               print help
 routes CONTROLLER  print routes
 exit               exit from rails-sh
 restart            restart rails-sh
 system             execute a system command
 eval               eval as ruby script\e[0m
HELP
end

Command.define 'rake' do |arg|
  Rails::Sh::Rake.invoke(arg)
end

Command.define 'system' do |arg|
  system arg
end

Command.define '!' do |arg|
  Command[:system].call(arg)
end

Command.define 'eval' do |arg|
  puts "\e[34m=> #{eval(arg, binding, __FILE__, __LINE__).inspect}\e[0m"
end

Command.define 'restart' do
  puts 'restarting...'
  _exec File.expand_path($0)
end

Command.define 'exit' do
  _exit
end
