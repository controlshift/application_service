require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'spec_helper'

describe ApplicationService do
  subject { ApplicationService.new }

  describe "#current_object" do
    it "should allow set and get" do
      obj = double()
      as = ApplicationService.new
      as.current_object= obj
      as.current_object.should == obj
    end
  end

  describe "#save" do
    it "should let you save an object" do
      obj = double()
      obj.stub(:new_record?).and_return(true)
      obj.should_receive(:save)
      subject.save(obj)
    end

    it "should trigger create" do
      obj = double()
      obj.stub(:new_record?).and_return(true)
      obj.stub(:save)

      subject.should_receive(:create)
      subject.save(obj)
    end


    it "should trigger update" do
      obj = double()
      obj.stub(:new_record?).and_return(false)
      obj.stub(:save)

      subject.should_receive(:update)
      subject.save(obj)
    end
  end

  describe "#save!" do
    it "should let you save an object" do
      obj = double()
      obj.stub(:new_record?).and_return(true)
      obj.should_receive(:save!)
      subject.save!(obj)
    end

    it "should trigger create" do
      obj = double()
      obj.stub(:new_record?).and_return(true)
      obj.stub(:save!)

      subject.should_receive(:create!)
      subject.save!(obj)
    end


    it "should trigger update" do
      obj = double()
      obj.stub(:new_record?).and_return(false)
      obj.stub(:save!)

      subject.should_receive(:update!)
      subject.save!(obj)
    end
  end

  describe "#update_attributes" do
    it "should trigger update" do
      obj = double()
      obj.should_receive(:assign_attributes).with( {:foo => 'bar'}).and_return(:true)
      obj.should_receive(:save)

      subject.update_attributes(obj, {:foo => 'bar'})
    end
  end

  describe '#destroy' do
    it "should trigger destroy" do
      obj = double()
      obj.should_receive(:destroy)

      subject.destroy(obj)
    end
  end

  describe '#admin_save' do
    it "should trigger admin_save if defined on object" do
      obj = double(new_record?: true)
      expect(obj).to receive(:admin_save)

      subject.admin_save(obj)
    end

    it "should trigger regular save if admin_save not defined on object" do
      obj = double(new_record?: true)
      expect(obj).to receive(:save)

      subject.admin_save(obj)
    end

    describe 'callbacks' do
      let(:object) { double(new_record?: false, save: true) }

      context 'invoke' do
        it "should invoke callbacks if skip_on_admin_save is false" do
          service_klass = Class.new(ApplicationService) do
            before :save, :before_save_callback, skip_on_admin_save: false
            after :save, :after_save_callback, skip_on_admin_save: false
          end

          service = service_klass.new
          expect(service).to receive(:before_save_callback)
          expect(service).to receive(:after_save_callback)

          service.admin_save(object)
        end

        it "should invoke callbacks if skip_on_admin_save option missing" do
          service_klass = Class.new(ApplicationService) do
            before :save, :before_save_callback
            after :save, :after_save_callback
          end

          service = service_klass.new
          expect(service).to receive(:before_save_callback)
          expect(service).to receive(:after_save_callback)

          service.admin_save(object)
        end

        it "should invoke callbacks on save even if skip_on_admin_save is true" do
          service_klass = Class.new(ApplicationService) do
            before :save, :before_save_callback, skip_on_admin_save: true
            after :save, :after_save_callback, skip_on_admin_save: true
          end

          service = service_klass.new
          expect(service).to receive(:before_save_callback)
          expect(service).to receive(:after_save_callback)

          service.save(object)
        end

        it "should invoke callbacks on save even if admin_save raises exception" do
          service_klass = Class.new(ApplicationService) do
            before :save, :before_save_callback, skip_on_admin_save: true
            after :save, :after_save_callback, skip_on_admin_save: true
          end

          expect(object).to receive(:save).and_raise(StandardError)

          service = service_klass.new
          expect(service).to receive(:before_save_callback).once
          expect(service).to receive(:after_save_callback).once

          expect { service.admin_save(object) }.to raise_error

          expect(object).to receive(:save).and_return(true)

          service.save(object)
        end
      end

      context 'skip' do
        it "should skip callbacks if skip_on_admin_save for create" do
          service_klass = Class.new(ApplicationService) do
            before :create, :before_create_callback, skip_on_admin_save: true
            after :create, :after_create_callback, skip_on_admin_save: true
          end

          service = service_klass.new
          expect(service).not_to receive(:before_create_callback)
          expect(service).not_to receive(:after_create_callback)

          service.admin_save(object)
        end

        it "should skip callbacks if skip_on_admin_save for update" do
          service_klass = Class.new(ApplicationService) do
            before :save, :before_save_callback, skip_on_admin_save: true
            after :save, :after_save_callback, skip_on_admin_save: true
          end

          service = service_klass.new
          expect(service).not_to receive(:before_save_callback)
          expect(service).not_to receive(:after_save_callback)

          service.admin_save(object)
        end
      end
    end
  end

  describe 'callbacks' do
    let(:object) { double(new_record?: false, save: true) }

    describe '#before' do
      it "should allow option as last argument for single callback method" do
        invoke_callback = false

        service_klass = Class.new(ApplicationService) do
          before :save, :before_save_callback, if: -> { invoke_callback }
        end

        service = service_klass.new
        service.should_not_receive(:before_save_callback)
        service.save(object)

        invoke_callback = true
        service = service_klass.new
        service.should_receive(:before_save_callback).and_return(true)
        service.save(object)
      end

      it "should allow option as last argument for multiple callback methods" do
        invoke_callback = false

        service_klass = Class.new(ApplicationService) do
          before :save, :before_save_callback_1, :before_save_callback_2, if: -> { invoke_callback }
        end

        service = service_klass.new
        service.should_not_receive(:before_save_callback_1)
        service.should_not_receive(:before_save_callback_2)
        service.save(object)

        invoke_callback = true
        service = service_klass.new
        service.should_receive(:before_save_callback_1).and_return(true)
        service.should_receive(:before_save_callback_2).and_return(true)
        service.save(object)
      end

      it "should not invoke callback if halted without options" do
        pending('Need to look deeper on ActiveSupport::Callback code to understand how halt works')

        service_klass = Class.new(ApplicationService) do
          before :save, :before_save_callback
        end

        service = service_klass.new
        service.should_not_receive(:before_save_callback)
        service.stub(:halted).and_return(true)
        service.save(object)
      end

      it "should not invoke callback if halted with options" do
        pending('Need to look deeper on ActiveSupport::Callback code to understand how halt works')

        service_klass = Class.new(ApplicationService) do
          before :save, :before_save_callback, if: 'true'
        end

        service = service_klass.new
        service.should_not_receive(:before_save_callback)
        service.stub(:halted).and_return(true)
        service.save(object)
      end
    end

    describe '#after' do
      it "should allow option as last argument for single callback method" do
        invoke_callback = false

        service_klass = Class.new(ApplicationService) do
          after :save, :after_save_callback, if: -> { invoke_callback }
        end

        service = service_klass.new
        service.should_not_receive(:after_save_callback)
        service.save(object)

        invoke_callback = true
        service = service_klass.new
        service.should_receive(:after_save_callback).and_return(true)
        service.save(object)
      end

      it "should allow option as last argument for multiple callback methods" do
        invoke_callback = false

        service_klass = Class.new(ApplicationService) do
          after :save, :after_save_callback_1, :after_save_callback_2, if: -> { invoke_callback }
        end

        service = service_klass.new
        service.should_not_receive(:after_save_callback_1)
        service.should_not_receive(:after_save_callback_2)
        service.save(object)

        invoke_callback = true
        service = service_klass.new
        service.should_receive(:after_save_callback_1).and_return(true)
        service.should_receive(:after_save_callback_2).and_return(true)
        service.save(object)
      end
    end
  end
end
