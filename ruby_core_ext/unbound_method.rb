require_relative '../parsing/source_code_reader'
require_relative '../parsing/source_code_atomic'

class UnboundMethod
  def is_native?
    source_location.nil?
  end

  def atomic_source_code
    original_method_def_src = SourceCodeReader.new.get_src_of_first_expression_in(*source_location)
    atomic_source_code = SourceCodeAtomic.new.atomic_source_of_method(original_method_def_src)
    #puts atomic_source_code
    atomic_source_code
  end
end