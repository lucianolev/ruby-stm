require_relative '../ruby_core_ext/symbol'
require_relative 'local_vars_in_scope'

if RUBY_ENGINE == 'rbx'
  require_relative 'rbx/ast_atomic_rewriter'
end

class ASTAtomicRewriter < Parser::AST::Processor
  def initialize(a_binding=nil)
    @local_vars_in_scope = LocalVarsInScope.new(a_binding)

    if RUBY_ENGINE == 'rbx'
      @local_vars_in_privately_node = LocalVarsInAST.new
    end
  end

  def on_send(node) # e.g.: obj.a_message
    receiver_node, method_name, *arg_nodes = *node

    receiver_node = process(receiver_node) if receiver_node

    if should_transform_to_atomic?(node)
      method_name = method_name.to_atomic_method_name
    end

    # continue processing...
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

  def should_transform_to_atomic?(send_node)
    _, method_name, *_ = *send_node

    # When accessing a local variable defined in outer scope, the parser cannot distinguish it from a message sent
    # without arguments and an explicit receiver. We should check if this send node corresponds to a local variable
    # gathered from current scope (on initialization)
    if @local_vars_in_scope.include?(method_name)
      return false
    end

    if RUBY_ENGINE == 'rbx'
      # Rubinius implements a special compiler macro called Rubinius.privately which executes code inside a block
      # in a special way. Variables inside that macro should be treated as if they were defined _outside_ that block.
      # We should check if this send node corresponds to a local variable gathered from parsing a Rubinius.privately
      # block node before.
      if @local_vars_in_privately_node.include?(method_name)
        return false
      end

      # Some Rubinius' send nodes are NOT defined as methods. Instead they are transformed using defined AST
      # transformations found in the kernel which emit a special bytecode instead of a normal message send. We should
      # not transform this nodes to atomic because if they are transformed, the transformations will not be applied
      # due to unmatching method method_name so the interpreter will raise an unhandlable method_missing.
      if is_a_rbx_undefined_method_node?(send_node)
        return false
      end

      # Rubinius.asm special macro will execute bytecode passed as a block parameter. We do not want to perform any
      # transformation when we are inside those special blocks.
      if currently_inside_rbx_asm_block?
        return false
      end
    end

    true
  end
end