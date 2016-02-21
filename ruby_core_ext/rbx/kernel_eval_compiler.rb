require 'rubinius/compiler'
require 'rubinius/code/ast'

class KernelEvalCompiler < Rubinius::ToolSets::Runtime::Compiler

  # Alternative compile_eval to enable :kernel category transformations
  # Code based on runtime/gems/rubinius-compiler-2.3.1/lib/rubinius/compiler/compiler.rb:286
  def self.compile_eval(string, variable_scope, file="(eval)", line=1)
    if ec = @eval_cache
      layout = variable_scope.local_layout
      if code = ec.retrieve([string, layout, line])
        return code
      end
    end

    compiler = new :eval, :compiled_code

    parser = compiler.parser
    parser.root CodeTools::AST::EvalExpression
    parser.default_transforms
    parser.enable_category :kernel
    parser.input string, file, line

    compiler.generator.variable_scope = variable_scope

    code = compiler.run

    code.add_metadata :for_eval, true

    if ec and parser.should_cache?
      ec.set([string.dup, layout, line], code)
    end

    return code
  end
end