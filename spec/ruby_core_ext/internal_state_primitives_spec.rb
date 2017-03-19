require 'rspec'
require_relative '../../src/ruby_core_ext/object'

describe 'Internal state primitives (Object extension)' do

  context 'Test shallow copy generates identical objects for primitive mutable classes' do

    it 'should correctly check if a String is identical to its copy' do
      a_string = 'hello hello'
      another_string = a_string.shallow_copy
      different_string = 'good bye'
      expect(a_string.has_same_object_state?(another_string)).to eq(true)
      expect(a_string.has_same_object_state?(different_string)).to eq(false)
    end

    it 'should correctly check if an Array is identical to its copy' do
      an_array = [1, 2, 3]
      another_array = an_array.shallow_copy
      different_array = [2, 3, 4]
      expect(an_array.has_same_object_state?(another_array)).to eq(true)
      expect(an_array.has_same_object_state?(different_array)).to eq(false)
    end

    it 'should correctly check if a Hash is identical to its copy' do
      a_hash = {:symbol => 1, 2 => 3}
      another_hash = a_hash.shallow_copy
      dif_key_hash = {:another_symbol => 1, 2 => 3}
      dif_value_hash = {:symbol => 2, 2 => 3}
      expect(a_hash.has_same_object_state?(another_hash)).to eq(true)
      expect(a_hash.has_same_object_state?(dif_key_hash)).to eq(false)
      expect(a_hash.has_same_object_state?(dif_value_hash)).to eq(false)
    end

  end

  context 'Test shallow copy work on custom class objects' do
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

    it 'should say that an unchanged cloned object of a custom class its identical to the copy' do
      my_object = MyObject.new
      a_clone = my_object.shallow_copy
      a_clone.internal_var = 1
      expect(my_object.has_same_object_state?(a_clone)).to eq(true)
    end

    it 'should say that a cloned object of a custom class with a modified instance variable (using attr_accessor) is NOT identical to the copy' do
      my_object = MyObject.new
      a_clone = my_object.shallow_copy
      a_clone.internal_var = 2
      expect(my_object.has_same_object_state?(a_clone)).to eq(false)
    end

    it 'should say that a cloned object of a custom class with a modified instance variable (through a custom message) is NOT identical to the copy' do
      my_object = MyObject.new
      a_clone = my_object.shallow_copy
      a_clone.change_inst_var
      expect(my_object.has_same_object_state?(a_clone)).to eq(false)
    end

  end

  context 'Test shallow copy on classes' do
    it 'shallow copying a class copies its metaclass correctly' do
      class TestClass
        @class_ivar = 1

        def self.update_ivar
          @class_ivar += 1
        end
      end

      class_copy = TestClass.shallow_copy
      expect(TestClass.update_ivar).to eq(2)
      expect(class_copy.update_ivar).to eq(2)
    end
  end

end

