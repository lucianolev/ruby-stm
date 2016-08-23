class Symbol

  def is_an_atomic_method_name?
    self.to_s.start_with? atomic_method_prefix
  end

  def to_atomic_method_name
    if is_an_atomic_method_name?
      self
    else
      if is_operator?
        non_atomic_name = operator_to_name(self)
      else
        non_atomic_name = self
      end
      (atomic_method_prefix + non_atomic_name.to_s).to_sym
    end
  end

  def to_nonatomic_method_name
    if is_an_atomic_method_name?
      non_atomic_name = self.to_s.sub(atomic_method_prefix, '').to_sym
      if is_an_operator_name?(non_atomic_name)
        name_to_operator(non_atomic_name)
      else
        non_atomic_name
      end
    else
      self
    end
  end

  def is_an_assign_ivar_method_name?
    self.to_s.end_with? '='
  end

  private

  def atomic_method_prefix
    '__atomic__'
  end

  def is_operator?
    operators_renaming_map.has_key?(self)
  end

  def operator_to_name(operator)
    operators_renaming_map[operator]
  end

  def name_to_operator(name)
    operators_renaming_map.key(name)
  end

  def is_an_operator_name?(name)
    operators_renaming_map.has_value?(name)
  end

  def operators_renaming_map
    # from http://ruby-doc.org/core-2.3.0/doc/syntax/methods_rdoc.html
    {
        :+ => :add,
        :- => :substract,
        :* => :multiply,
        :** => :power,
        :/ => :divide,
        :% => :modulus_division,
        :& => :and,
        :^ => :xor,
        :>> => :shift_right,
        :<< => :shift_left,
        :== => :equal,
        :!= => :not_equal,
        :=== => :case_equality,
        :=~ => :pattern_match,
        :!~ => :does_not_match,
        :<=> => :comparison,
        :< => :less_than,
        :<= => :less_or_eq_than,
        :> => :greater_than,
        :>= => :greater_or_eq_than,
        :-@ => :minus_unary,
        :+@ => :plus_unary,
        :~@ => :tilde_unary,
        ':!@'.to_sym => :not_unary,
        :[]= => :set_index,
        :[] => :at,
        :| => :pipe, # not documented?
    }
  end
end