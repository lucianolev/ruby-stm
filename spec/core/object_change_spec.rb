require 'rspec'
require_relative '../../core/object_change'

describe ObjectChange do
  context 'Test object change on custom class object' do
    before do
      class MyObject
        attr_accessor :internal_var

        def initialize
          @internal_var = 1
        end
      end
      @custom_class_object = MyObject.new
      @object_change = ObjectChange.new(@custom_class_object)
    end

    it 'should correctly detect that an object of a custom class didnt change if nothing is performed in the object' do
      @object_change.working.internal_var
      expect(@object_change.has_changed?).to eq(false)
    end

    it 'should correctly detect that an object of a custom class has changed when changing an instance variable' do
      @object_change.working.internal_var = 2
      expect(@object_change.has_changed?).to eq(true)
    end
  end

  context 'Tests using array' do
    it 'should correctly detect that an array object didnt change' do
      @an_array = [1, 2, 3]
      @object_change = ObjectChange.new(@an_array)
      @object_change.working[0] = 1
      expect(@object_change.has_changed?).to eq(false)
    end
    it 'should correctly detect that an array object has changed when using the [] operator' do
      @an_array = [1, 2, 3]
      @object_change = ObjectChange.new(@an_array)
      @object_change.working[1] = 7
      expect(@object_change.has_changed?).to eq(true)
    end
  end
end