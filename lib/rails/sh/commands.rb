include Rails::Sh

Command.define 'help' do
  puts <<HELP
\e[36mhelp               print help
rails ARG          execute rails command
rake TASK          execute rake task
t, tasks PATTERN   print rake tasks
exit               exit from rails-sh
restart            restart rails-sh
reload             reload the environment
!, system          execute a system command
eval               eval as ruby script\e[0m
HELP
end

Command.define 'rails' do |arg|
  Rails::Sh.execute_rails_command(arg)
end

Command.define 'rake' do |arg|
  Rails::Sh::Rake.invoke(arg || :default)
end

Command.define 'tasks', 't' do |arg|
  Rake.application.options.show_task_pattern = arg ? Regexp.new(arg) : //
  Rake.application.display_tasks_and_comments
end

Command.define 'system', '!' do |arg|
  system arg
end

Command.define 'eval' do |arg|
  puts "\e[34m=> #{eval(arg, binding, __FILE__, __LINE__).inspect}\e[0m"
end

Command.define 'restart' do
  puts 'restarting...'
  exec File.expand_path('../../../../bin/rails-sh', __FILE__)
end

Command.define 'reload' do
  Rails::Sh.reload!
end

Command.define 'exit' do
  exit
end
