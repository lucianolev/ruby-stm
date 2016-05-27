require 'rspec'
require_relative '../../src/ruby_core_ext/object'

describe Object do

  context 'Test same internal state recognition of primitive morphable objects' do

    it 'should correctly check if another String has the same internal state' do
      a_string = 'Hello hello'
      another_string = 'Hello hello'
      different_string = 'Hello goodbye'
      expect(a_string.has_same_internal_state?(another_string)).to eq(true)
      expect(a_string.has_same_internal_state?(different_string)).to eq(false)
    end

    it 'should correctly check if another Array has the same internal state' do
      an_array = [1, 2, 3]
      another_array = [1, 2, 3]
      different_array = [1, 2, 5]
      expect(an_array.has_same_internal_state?(another_array)).to eq(true)
      expect(an_array.has_same_internal_state?(different_array)).to eq(false)
    end

    it 'should correctly check if another Hash has the same internal state' do
      a_hash = {:symbol => 1, 2 => 3}
      another_hash = {:symbol => 1, 2 => 3}
      dif_key_hash = {:another_symbol => 1, 2 => 3}
      dif_value_hash = {:symbol => 1, 2 => 5}
      expect(a_hash.has_same_internal_state?(another_hash)).to eq(true)
      expect(a_hash.has_same_internal_state?(dif_key_hash)).to eq(false)
      expect(a_hash.has_same_internal_state?(dif_value_hash)).to eq(false)
    end

  end

  context 'Test same internal state recognition of custom class objects' do
    before do
      class MyObject
        attr_accessor :internal_var

        def initialize
          @internal_var = 1
        end

        def change_inst_var
          my_local = 8
          @internal_var = my_local
        end
      end
    end

    it 'should say that an unchanged cloned object of a custom class has the same internal state' do
      my_object = MyObject.new
      a_clone = my_object.clone
      a_clone.internal_var = 1
      expect(my_object.has_same_internal_state?(a_clone)).to eq(true)
    end

    it 'should say that a cloned object of a custom class with a modified instance variable (using attr_accessor)
  has NOT the same internal state' do
      my_object = MyObject.new
      a_clone = my_object.clone
      a_clone.internal_var = 2
      expect(my_object.has_same_internal_state?(a_clone)).to eq(false)
    end

    it 'should say that a cloned object of a custom class with a modified instance variable (through a custom message)
 has NOT the same internal state' do
      my_object = MyObject.new
      a_clone = my_object.clone
      a_clone.change_inst_var
      expect(my_object.has_same_internal_state?(a_clone)).to eq(false)
    end

  end

end

