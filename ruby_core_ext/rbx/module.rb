require_relative 'kernel_eval_compiler'

class Module
  def class_eval_with_kernel_code_support(string, filename="(eval)", line=1)
    # Code below from Module#module_eval found in kernel/common/eval.rb:175 (rbx-3.14),
    # with an alternative custom compiler (KernelEvalCompiler)

    string = StringValue(string)
    filename = StringValue(filename)

    # The constantscope of a module_eval CM is the receiver of module_eval
    cs = Rubinius::ConstantScope.new self, Rubinius::ConstantScope.of_sender

    binding = Binding.setup(Rubinius::VariableScope.of_sender,
                            Rubinius::CompiledCode.of_sender,
                            cs)

    c = KernelEvalCompiler
    be = c.construct_block string, binding, filename, line

    be.call_under self, cs, true, self
  end
end