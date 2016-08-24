require_relative '../../symbol'

module ThreadSafe
  class Hash < ::Hash;
  end
  class Array < ::Array;
  end

  # NOTE: thread-safe lib defines a wrapper for all array and hash
  #   methods using class_eval. As this implementation does not
  #   allow code transformation for meta-programming methods like
  #   class_eval, we define manually the atomic variant of those
  #   methods.
  #   The definition is the same, as the syncronize method of
  #   Monitor does not need to be run inside a transaction.
  [Hash, Array].each do |klass|
    klass.superclass.instance_methods(false).each do |method|
      klass.class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
          def #{method.to_atomic_method_name}(*args)
            @_monitor.synchronize { super }
          end
      RUBY_EVAL
    end
  end
end