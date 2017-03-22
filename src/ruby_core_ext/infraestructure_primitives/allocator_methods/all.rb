require_relative 'class'

if RUBY_ENGINE == 'rbx'
  require_relative 'rbx/byte_array'
  require_relative 'rbx/proc'
  require_relative 'rbx/string'
  require_relative 'rbx/tuple'
end
