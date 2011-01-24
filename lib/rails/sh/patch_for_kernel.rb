module Kernel
  alias_method :_require, :require
  def require(name)
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
end