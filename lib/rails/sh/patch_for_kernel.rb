module Kernel
  alias_method :_require, :require
  def require(name)
    name = name.to_path if name.respond_to?(:to_path)
    if name =~ /^rails\/commands\//
      load "#{name}.rb"
    else
      _require(name)
    end
  end

  alias_method :_exec, :exec
  def exec(*args)
    system(*args)
  end

  alias_method :_exit, :exit
  def exit(*args)
    irb_exit if caller.first =~ /irb_binding/
  end
end