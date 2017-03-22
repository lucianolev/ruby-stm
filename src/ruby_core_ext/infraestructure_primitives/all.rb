require_relative 'module'
require_relative 'fiber'
require_relative 'proc'

if RUBY_ENGINE == 'ruby'
  require_relative 'mri/kernel'
  require_relative 'mri/thread'
end

if RUBY_ENGINE == 'rbx'
  require_relative 'rbx/kernel'
  require_relative 'rbx/rubinius'
  require_relative 'rbx/type'
end

require_relative 'allocator_methods/all'
