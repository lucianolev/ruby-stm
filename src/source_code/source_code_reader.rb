class SourceCodeReader

  def get_src_of_first_expression_in(file, linenum)
    lines = IO.readlines(file)
    lines_from_linenum = lines[linenum-1..-1]
    extract_first_expression(lines_from_linenum)
  end

  private

  # based on https://github.com/banister/method_source/blob/master/lib/method_source/code_helpers.rb#L92
  def extract_first_expression(lines)
    code = ''
    lines.each do |v|
      code << v
      return code if complete_expression?(code)
    end
    raise SyntaxError, 'unexpected $end'
  end

  # based on https://github.com/banister/method_source/blob/master/lib/method_source/code_helpers.rb#L66
  def complete_expression?(str)
    catch(:valid) do
      eval("BEGIN{throw :valid}\n#{str}")
    end

    # Assert that a line which ends with a , or \ is incomplete.
    str !~ /[,\\]\s*\z/
  rescue IncompleteExpression
    false
  end
end

# based on https://github.com/banister/method_source/blob/master/lib/method_source/code_helpers.rb#L124
class IncompleteExpression
  GENERIC_REGEXPS = [
      /unexpected (\$end|end-of-file|end-of-input|END_OF_FILE)/, # mri, jruby, ruby-2.0, ironruby
      /embedded document meets end of file/, # =begin
      /unterminated (quoted string|string|regexp) meets end of file/, # "quoted string" is ironruby
      /can't find string ".*" anywhere before EOF/, # rbx and jruby
      /missing 'end' for/, /expecting keyword_when/ # rbx
  ]

  RBX_ONLY_REGEXPS = [
      /expecting '[})\]]'(?:$|:)/, /expecting keyword_end/
  ]

  def self.===(ex)
    return false unless SyntaxError === ex
    case ex.message
      when *GENERIC_REGEXPS
        true
      when *RBX_ONLY_REGEXPS
        rbx?
      else
        false
    end
  end

  def self.rbx?
    RbConfig::CONFIG['ruby_install_name'] == 'rbx'
  end
end