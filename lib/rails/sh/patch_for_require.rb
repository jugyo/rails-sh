module Kernel
  alias_method :_require, :require
  def require(name)
    if name =~ /^rails\/commands\//
      load "#{name}.rb"
    else
      _require(name)
    end
  end
end