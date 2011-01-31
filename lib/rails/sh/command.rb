module Rails
  module Sh
    class Command
      class << self
        def commands
          @commands ||= {}
        end

        def define(name, &block)
          commands[name.to_sym] = block
        end

        def find(line)
          if name = line.split(/\s+/, 2)[0]
            commands[name.to_sym]
          else
            nil
          end
        end

        def command_names
          commands.keys
        end

        def [](name)
          commands[name]
        end
      end
    end
  end
end

module Kernel
  alias_method :_exit, :exit
  def exit(*args); end
end

Rails::Sh::Command.define 'help' do
  Rails::Sh.execute_rails_command('--help')
  puts <<HELP

The rails-sh commands are:
 help               print help
 routes CONTROLLER  print routes
 exit               exit from rails-sh
HELP
end

Rails::Sh::Command.define 'routes' do |controller|
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

Rails::Sh::Command.define 'exit' do
  _exit
end