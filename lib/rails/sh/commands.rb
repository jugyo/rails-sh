include Rails::Sh

Command.define 'help' do
  print "\e[36m"
  puts <<HELP
help              print help
rails ARG         execute rails command
rake TASK         execute rake task
t, tasks PATTERN  print rake tasks
bundle            execute bundler command
exit              exit from rails-sh
restart           restart rails-sh
reload            reload the environment
!                 execute a system command
eval              eval as ruby script
HELP
  print "\e[0m"
end

Command.define 'rails' do |arg|
  Rails::Sh::Rails.invoke(arg)
end

Rails::Sh::Rails.sub_commands.map do |c|
  Command.completions << "rails #{c}"
end

Command.define 'rake' do |arg|
  Rails::Sh::Rake.invoke(arg)
end

Rails::Sh::Rake.task_names.map do |name|
  Command.completions << "rake #{name}"
end

Command.define 'tasks', 't' do |arg|
  Rake.application.options.show_task_pattern = arg ? Regexp.new(arg) : //
  Rake.application.display_tasks_and_comments
end

Command.define 'bundle' do |arg|
  Rails::Sh::Bundler.invoke(arg)
end

(Rails::Sh::Bundler.sub_commands - ['init']).map do |c|
  Command.completions << "bundle #{c}"
end

Command.define '!' do |arg|
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
  Rails::Sh::Rails.reload!
end

Command.define 'log' do |arg|
  puts "\e[7mCtrl-C to quit\e[0m"
  system 'tail', '-f', Rails.root.join('log', (arg || 'development') + '.log').to_s
end
Command.completions += %w(development test production).map { |i| "log #{i}" }

Command.define 'exit' do
  exit
end
