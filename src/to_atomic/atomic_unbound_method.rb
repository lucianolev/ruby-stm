require_relative 'atomic_callable'
require_relative 'atomic_rewriters/atomic_send_rewriter'

if RUBY_ENGINE == 'rbx'
  require_relative 'atomic_rewriters/rbx/atomic_send_on_rbx_rewriter'
  require_relative 'atomic_rewriters/rbx/remove_rbx_primitives_rewriter'
end

class AtomicUnboundMethod < AtomicCallable
  def name
    original.name.to_atomic_method_name
  end

  def owner
    original.owner
  end

  def source_code
    source_code = original.source_code
    source_code.change_name_in_definition!(name)
    transform_to_atomic(source_code)
  end

  private

  def generate_atomic
    define_in_owner
    define_aliases
    Module.register_module_with_an_atomic_method(owner)
    if owner.is_a?(Class)
      generate_atomic_methods_for_subclasses
    end
    owner.instance_method(name)
  end

  def define_in_owner
    if should_not_transform?
      owner.send(:define_method, name, original)
      # puts "DEBUG: Atomic method defined #{self.owner}##{self.name} (untransformed)"
    elsif should_send_through_working_copy?
      owner.send(:define_method, name,
                 original_through_working_copy)
      # puts "DEBUG: Atomic method defined #{self.owner}##{self.name} (through working copy)"
    else
      owner.send(:define_method_using_source_code, name,
                 source_code)
      # puts 'DEBUG: -----------------------------------------'
      # puts "DEBUG: Atomic method defined #{self.owner}##{self.name}."
      # puts "DEBUG: Source code:\n#{self.source_code.to_s}"
      # puts 'DEBUG: -----------------------------------------'
    end
  end

  def define_aliases
    owner.aliased_methods(original) do |meth_name|
      alias_method(meth_name.to_atomic_method_name,
                   name)
    end
  end

  def generate_atomic_methods_for_subclasses
    subclasses = owner.subclasses_implementing_message(original.name)
    subclasses.each do |subclass|
      subclass_methods = subclass.instance_methods(false)
      unless subclass_methods.include?(name)
        original_method = subclass.instance_method(original.name)
        AtomicUnboundMethod.from(original_method)
      end
    end
  end

  def should_not_transform?
    owner.immutable_instances? ||
        owner.is_infraestructure_primitive?(original.name)
  end

  def should_send_through_working_copy?
    owner.mutable_primitive_instances? ||
        owner.is_a_mutable_primitive?(original.name)
  end

  def original_through_working_copy
    ->(*args, &block) do
      working_copy.send(__method__.to_nonatomic_method_name, *args,
                        &block)
    end
  end

  if RUBY_ENGINE == 'rbx'
    def transform_to_atomic(source_code)
      remove_rbx_primitives!(source_code)
      super
    end

    def atomic_send_rewriter
      AtomicSendOnRbxRewriter.new
    end

    def remove_rbx_primitives!(source_code)
      src_rewriter = source_code.new_source_rewriter
      remove_primitives = RemoveRbxPrimitivesRewriter.new(src_rewriter)
      src_rewriter = remove_primitives.do(source_code.to_ast)
      source_code.apply_source_rewrite!(src_rewriter)
    end
  end
end