require_relative '../atomic_send_rewriter'
require_relative '../local_vars_in_ast'

class AtomicSendOnRbxRewriter < AtomicSendRewriter
  def initialize(a_binding=nil)
    super

    @local_vars_in_privately_node = LocalVarsInAST.new
    @currently_inside_rbx_asm_block = false
  end

  def on_block(node)
    send_node, _, body_node = *node
    receiver_node, method_name, *_ = *send_node

    # Rubinius implements a special compiler macro called Rubinius.privately which executes code inside a block
    # in a special way. Variables inside that macro should be treated as if they were defined _outside_ that block.
    # So we add local variables found inside block to them to be excluded during on_send calls.
    if is_rbx_privately_node?(receiver_node, method_name)
      @local_vars_in_privately_node.add_from_tree(body_node)
    end

    # If this is a Rubinius.asm block node, we should register that fact before processing, so any send nodes
    # processed afterwards are not transformed during future on_send calls for the current subtree.
    if is_rbx_asm_node?(receiver_node, method_name)
      @currently_inside_rbx_asm_block = true
      processed_node = super
      @currently_inside_rbx_asm_block = false
      return processed_node
    end

    # continue processing...
    super
  end

  private

  def should_transform_to_atomic?(send_node)
    _, method_name, *_ = *send_node

    unless super
      return false
    end

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

    true
  end

  def is_rbx_privately_node?(receiver_node, method_name)
    !receiver_node.nil? && receiver_node.children[1] == :Rubinius &&
        method_name == :privately
  end

  def is_rbx_asm_node?(receiver_node, method_name)
    !receiver_node.nil? && receiver_node.children[1] == :Rubinius &&
        method_name == :asm
  end

  def currently_inside_rbx_asm_block?
    @currently_inside_rbx_asm_block
  end

  def is_a_rbx_undefined_method_node?(node)
    receiver_node, method_name, *_ = *node

    # based on the analysis of lib/rubinius/code/ast/transforms.rb in the rubinius-ast-3.8 gem
    if not receiver_node.nil?
      primitives = [:primitive, :invoke_primitive, :check_frozen,
                    :call_custom, :single_block_arg, :asm,
                    :privately]
      is_rbx_primitive = receiver_node.children[1] == :Rubinius &&
          primitives.include?(method_name)

      undef_equal_send = receiver_node.children[1] == :undefined &&
          method_name == :equal?

      is_rbx_primitive || undef_equal_send
    else
      [:undefined, :block_given?, :iterator?].include?(method_name)
    end
  end

end