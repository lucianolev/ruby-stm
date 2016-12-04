require_relative '../ruby_core_ext/symbol'

class ASTAtomicRewriter < Parser::AST::Processor
  def initialize(a_binding=nil)
    @source_binding = a_binding
  end

  def on_send(node) # e.g.: obj.a_message
    receiver_node, method_name, *arg_nodes = *node

    receiver_node = process(receiver_node) if receiver_node

    # When accessing a local variable defined in outer scope, the parser cannot distinguish it from a message sent
    # wihout arguments and an explicit receiver. In that case we can desambiguate the situation by looking
    # if the supposed 'method_name' is not indeed a local variable. So, we do the atomic name transformation unless
    # it's a local variable.
    unless is_a_local_variable?(method_name)
      if RUBY_ENGINE == 'rbx'
        # Some Rubinius' send nodes are NOT defined as methods. Instead they are transformed using defined AST
        # transformations found in the kernel which emit a special bytecode instead of a normal message send. We should
        # not transform this nodes to atomic because if they are transformed, the transformations will not be applied
        # due to unmatching method name so the interpreter will raise an unhandlable method_missing.
        unless is_a_rbx_undefined_method_node?(receiver_node,
                                               method_name)
          method_name = method_name.to_atomic_method_name
        end
      else
        method_name = method_name.to_atomic_method_name
      end
    end

    node.updated(nil, [
        receiver_node, method_name, *process_all(arg_nodes)
    ])
  end

  def on_ivasgn(node) # e.g.: @instance_var = "some_value"
    var_name, value_node = *node

    node.updated(:send, [
        Parser::AST::Node.new(:self),
        :instance_variable_set.to_atomic_method_name,
        Parser::AST::Node.new(:sym, [var_name.to_sym]),
        process(value_node)
    ])
  end

  def on_ivar(node) # e.g.: @instance_var
    var_name = node.children.first

    node.updated(:send, [
        Parser::AST::Node.new(:self),
        :instance_variable_get.to_atomic_method_name,
        Parser::AST::Node.new(:sym, [var_name.to_sym])
    ])
  end

  private

  def is_a_rbx_undefined_method_node?(receiver_node, method_name)
    # based on the analysis of lib/rubinius/code/ast/transforms.rb in the rubinius-ast-3.8 gem
    if not receiver_node.nil?
      primitives = [:primitive, :invoke_primitive, :check_frozen,
                    :call_custom, :single_block_arg, :asm,
                    :privately]
      receiver_node.children[1] == :Rubinius &&
          primitives.include?(method_name)
    else
      [:undefined, :block_given?, :iterator?].include?(method_name)
    end
  end

  def is_a_local_variable?(method_name)
    begin
      !@source_binding.nil? and
          @source_binding.local_variable_defined?(method_name)
    rescue NameError # some method name are not valid local variable names so local_variable_defined? will raise a NameError
      false
    end
  end

end