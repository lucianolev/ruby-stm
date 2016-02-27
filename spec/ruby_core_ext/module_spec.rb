require 'rspec'
require_relative '../../ruby_core_ext/module'

describe Module do

  context 'Test atomic method names recognition and conversion' do

    it 'should correclty identify an atomic method' do
      expect(self.class.method_is_atomic?(:a_normal_method_name)).to eq(false)
      expect(self.class.method_is_atomic?(:+)).to eq(false)
      expect(self.class.method_is_atomic?(:__atomic__method_name)).to eq(true)
    end

    it 'should return the non-atomic name of an atomic method correclty' do
      expect(self.class.atomic_method_nonatomic_name(:__atomic__method_name)).to eq(:method_name)
      expect(self.class.atomic_method_nonatomic_name(:method_name)).to eq(:method_name)
      expect(self.class.atomic_method_nonatomic_name(:__atomic__add)).to eq(:+)
    end

    it 'should return the atomic name of a non-atomic method correclty' do
      expect(self.class.atomic_name_of(:method_name)).to eq(:__atomic__method_name)
      expect(self.class.atomic_name_of(:+)).to eq(:__atomic__add)
    end

  end

  context 'Test define atomic methods' do
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
  end
end