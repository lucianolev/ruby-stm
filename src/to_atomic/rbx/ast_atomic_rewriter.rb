require_relative '../local_vars_in_ast'

class ASTAtomicRewriter < Parser::AST::Processor

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
      processed_node = node.updated(nil, process_all(node))
      @currently_inside_rbx_asm_block = false
      return processed_node
    end

    # continue processing...
    node.updated(nil, process_all(node))
  end

  private

  def is_rbx_privately_node?(receiver_node, method_name)
    !receiver_node.nil? && receiver_node.children[1] == :Rubinius &&
        method_name == :privately
  end

  def is_rbx_asm_node?(receiver_node, method_name)
    !receiver_node.nil? && receiver_node.children[1] == :Rubinius &&
        method_name == :asm
  end

  def currently_inside_rbx_asm_block?
    if @currently_inside_rbx_asm_block.nil?
      @currently_inside_rbx_asm_block = false
    end
    @currently_inside_rbx_asm_block
  end

  def is_a_rbx_undefined_method_node?(node)
    receiver_node, method_name, *_ = *node

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

end