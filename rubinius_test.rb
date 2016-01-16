class RubyVM
  class InstructionSequence
    class << self
      alias :old_compile_file :compile_file
      def compile_file(code, opt)
        puts "Injecting code..."
        old_compile_file(code, opt)
      end
      alias :old_compile :compile
      def compile(code)
        puts "Injecting code..."
        old_compile(code)
      end
    end
  end
end

code = <<END

puts 2+2
END

puts RubyVM::InstructionSequence.compile(code).disasm

# class String
#   alias :old_size :size
#   def size
#     puts "el size es.."
#     old_size
#   end
# end
#
# puts "hello".size

# require 'rubinius/melbourne'
# require 'rubinius/processor'
# require 'rubinius/compiler'
# require 'rubinius/ast'
#
# class Proc
#   def atomic
#
#   end
# end
#
# a_proc = Proc.new {|a| a + 5}
#
# a_proc.atomic
#
# # puts a_proc.call(8)
#
# module CodeTools
#   class Melbourne
#     class << self
#       alias :old_parse_string :parse_string
#       def parse_string(string, name="(eval)", line=1)
#         puts "Injecting code poc..."
#         old_parse_string(string, name, line)
#       end
#     end
#   end
# end
#
# ast = CodeTools::Melbourne.parse_string('a_proc = Proc.new {|a| a + 5}')
#
# puts ast