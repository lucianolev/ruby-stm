require 'rspec'
require_relative '../../src/ruby_core_ext/module'

describe Module do
  context 'Test define and remove atomic methods' do
    before do
      class MyObject
        attr_accessor :internal_var

        @class_var = 1

        def initialize
          @internal_var = 1
        end

        def change_inst_var
          my_local = 8
          @internal_var = my_local
        end

        alias_method :alias_change_inst_var, :change_inst_var

        def self.change_class_var
          my_local = 5
          @class_var = my_local
        end
      end
    end

    it 'should define an atomic version of a non-native method correctly' do
      my_object = MyObject.new
      atomic_method_name = my_object.class.define_atomic_method(:change_inst_var)
      expect(my_object.class.instance_methods).to include(atomic_method_name)
    end

    it 'should define an atomic version of a non-native class method correctly' do
      my_object = MyObject.new
      atomic_method_name = my_object.class.singleton_class.define_atomic_method(:change_class_var)
      expect(my_object.class.methods).to include(atomic_method_name)
    end

    it 'should define an atomic version of a native method correctly' do
      my_object = MyObject.new
      atomic_method_name = my_object.class.define_atomic_method(:to_s)
      expect(my_object.class.instance_methods).to include(atomic_method_name)
    end

    it 'should define an atomic version of an aliased method correctly' do
      my_object = MyObject.new
      atomic_method_name = my_object.class.define_atomic_method(:alias_change_inst_var)
      expect(my_object.class.instance_methods).to include(atomic_method_name)
    end

    it 'should remove all atomic methods correctly' do
      my_object = MyObject.new

      atomic_method_name = my_object.class.define_atomic_method(:change_inst_var)

      expect(my_object.class.instance_methods).to include(atomic_method_name)
      Module.remove_all_atomic_methods
      expect(my_object.class.instance_methods).not_to include(atomic_method_name)
    end
  end
end