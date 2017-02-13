require_relative 'object'

if RUBY_ENGINE == 'ruby'
  require_relative 'mri/array'
  require_relative 'mri/hash'
  require_relative 'mri/string'
end

if RUBY_ENGINE == 'rbx'
  require_relative 'rbx/object'
  require_relative 'rbx/byte_array'
  require_relative 'rbx/immediate'
  require_relative 'rbx/string'
  require_relative 'rbx/tuple'
end
