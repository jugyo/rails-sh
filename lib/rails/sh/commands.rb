module Kernel
  alias_method :_exit, :exit
  def exit(*args); end
end

module Rails::Sh
  Command.define 'help' do
    execute_rails_command('--help')
    puts <<HELP

The rails-sh commands are:
 help               print help
 routes CONTROLLER  print routes
 exit               exit from rails-sh
 system             execute a system command
 eval               eval as ruby script
HELP
  end

  Command.define 'routes' do |controller|
    Rails.application.reload_routes!
    all_routes = Rails.application.routes.routes

    if controller.present?
      all_routes = all_routes.select{ |route| route.defaults[:controller] == controller }
    end

    routes = all_routes.collect do |route|

      reqs = route.requirements.dup
      reqs[:to] = route.app unless route.app.class.name.to_s =~ /^ActionDispatch::Routing/
      reqs = reqs.empty? ? "" : reqs.inspect

      {:name => route.name.to_s, :verb => route.verb.to_s, :path => route.path, :reqs => reqs}
    end

    routes.reject! { |r| r[:path] =~ %r{/rails/info/properties} } # Skip the route if it's internal info route

    name_width = routes.map{ |r| r[:name].length }.max
    verb_width = routes.map{ |r| r[:verb].length }.max
    path_width = routes.map{ |r| r[:path].length }.max

    routes.each do |r|
      puts "#{r[:name].rjust(name_width)} #{r[:verb].ljust(verb_width)} #{r[:path].ljust(path_width)} #{r[:reqs]}"
    end
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

  Command.define 'exit' do
    _exit
  end
end