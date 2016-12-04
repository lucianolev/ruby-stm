require_relative 'kernel_eval_compiler'

class Module

  def module_eval_with_kernel_code_support(string, filename="(eval)", line=1)
    # Code below from Module#module_eval found in core/module.rb:138 (rbx-3.58),
    # with an alternative custom compiler (KernelEvalCompiler)

    string = StringValue(string)
    filename = StringValue(filename)

    # The constantscope of a module_eval CM is the receiver of module_eval
    cs = Rubinius::LexicalScope.new self, Rubinius::LexicalScope.of_sender

    binding = Binding.setup(Rubinius::VariableScope.of_sender,
                            Rubinius::CompiledCode.of_sender,
                            cs)

    c = KernelEvalCompiler
    be = c.construct_block string, binding, filename, line

    be.call_under self, cs, true, self
  end

  alias_method :class_eval_with_kernel_code_support, :module_eval_with_kernel_code_support

end