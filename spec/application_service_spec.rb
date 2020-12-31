require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'spec_helper'

describe ApplicationService do
  subject { ApplicationService.new }

  describe "#current_object" do
    it "should allow set and get" do
      obj = double()
      as = ApplicationService.new
      as.current_object = obj
      expect(as.current_object).to eq(obj)
    end
  end

  describe "#save" do
    it "should let you save an object" do
      obj = double()
      allow(obj).to receive(:new_record?).and_return(true)
      expect(obj).to receive(:save)
      subject.save(obj)
    end

    it "should trigger create" do
      obj = double()
      allow(obj).to receive(:new_record?).and_return(true)
      allow(obj).to receive(:save)

      expect(subject).to receive(:create)
      subject.save(obj)
    end


    it "should trigger update" do
      obj = double()
      allow(obj).to receive(:new_record?).and_return(false)
      allow(obj).to receive(:save)

      expect(subject).to receive(:update)
      subject.save(obj)
    end
  end

  describe "#save!" do
    it "should let you save an object" do
      obj = double()
      allow(obj).to receive(:new_record?).and_return(true)
      expect(obj).to receive(:save!)
      subject.save!(obj)
    end

    it "should trigger create" do
      obj = double()
      allow(obj).to receive(:new_record?).and_return(true)
      allow(obj).to receive(:save!)

      expect(subject).to receive(:create!)
      subject.save!(obj)
    end


    it "should trigger update" do
      obj = double()
      allow(obj).to receive(:new_record?).and_return(false)
      allow(obj).to receive(:save!)

      expect(subject).to receive(:update!)
      subject.save!(obj)
    end
  end

  describe "#update_attributes" do
    it "should trigger update" do
      obj = double()
      expect(obj).to receive(:assign_attributes).with( {:foo => 'bar'}).and_return(:true)
      expect(obj).to receive(:save)

      subject.update_attributes(obj, {:foo => 'bar'})
    end
  end

  describe '#destroy' do
    it "should trigger destroy" do
      obj = double()
      expect(obj).to receive(:destroy)

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

          expect { service.admin_save(object) }.to raise_error(StandardError)

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
        expect(service).to_not receive(:before_save_callback)
        service.save(object)

        invoke_callback = true
        service = service_klass.new
        expect(service).to receive(:before_save_callback).and_return(true)
        service.save(object)
      end

      it "should allow option as last argument for multiple callback methods" do
        invoke_callback = false

        service_klass = Class.new(ApplicationService) do
          before :save, :before_save_callback_1, :before_save_callback_2, if: -> { invoke_callback }
        end

        service = service_klass.new
        expect(service).not_to receive(:before_save_callback_1)
        expect(service).not_to receive(:before_save_callback_2)
        service.save(object)

        invoke_callback = true
        service = service_klass.new
        expect(service).to receive(:before_save_callback_1).and_return(true)
        expect(service).to receive(:before_save_callback_2).and_return(true)
        service.save(object)
      end

      it "should not invoke callback if halted without options" do
        service_klass = Class.new(ApplicationService) do
          before :save, :before_save_callback1, :before_save_callback2
        end

        service = service_klass.new
        expect(service).not_to receive(:before_save_callback2)
        allow(service).to receive(:before_save_callback1).and_return(false)
        service.save(object)
      end

      it "should invoke callback if callback successful" do
        service_klass = Class.new(ApplicationService) do
          before :save, :before_save_callback1, :before_save_callback2
        end

        service = service_klass.new
        expect(service).to receive(:before_save_callback2)
        allow(service).to receive(:before_save_callback1).and_return(true)
        service.save(object)
      end

      it "should invoke subsequent callbacks if a callback is skipped with options" do
        service_klass = Class.new(ApplicationService) do
          before :save, :before_save_callback, if: -> { false }
          before :save, :before_save_callback_2

        end

        service = service_klass.new
        expect(service).not_to receive(:before_save_callback)
        expect(service).to receive(:before_save_callback_2)

        expect(object).to receive(:save).and_return(true)

        service.save(object)
      end

      it "should halt execution if callback fails" do
        service_klass = Class.new(ApplicationService) do
          before :save, :before_save_callback
        end

        service = service_klass.new
        allow(service).to receive(:before_save_callback).and_return(false)
        expect(object).not_to receive(:save)
        expect(service.save(object)).to eq(false)
      end

      it "should invoke callback if conditional is true" do
        service_klass = Class.new(ApplicationService) do
          before :save, :before_save_callback, if: -> { true }
        end

        service = service_klass.new
        expect(service).to receive(:before_save_callback).and_return(true)
        expect(service.save(object)).to eq(true)
      end
    end

    describe '#after' do
      it "should allow option as last argument for single callback method" do
        invoke_callback = false

        service_klass = Class.new(ApplicationService) do
          after :save, :after_save_callback, if: -> { invoke_callback }
        end

        service = service_klass.new
        expect(service).not_to receive(:after_save_callback)
        service.save(object)

        invoke_callback = true
        service = service_klass.new
        expect(service).to receive(:after_save_callback).and_return(true)
        service.save(object)
      end

      it "should allow option as last argument for multiple callback methods" do
        invoke_callback = false

        service_klass = Class.new(ApplicationService) do
          after :save, :after_save_callback_1, :after_save_callback_2, if: -> { invoke_callback }
        end

        service = service_klass.new
        expect(service).not_to receive(:after_save_callback_1)
        expect(service).not_to receive(:after_save_callback_2)
        service.save(object)

        invoke_callback = true
        service = service_klass.new
        expect(service).to receive(:after_save_callback_1).and_return(true)
        expect(service).to receive(:after_save_callback_2).and_return(true)
        service.save(object)
      end

      it "should invoke callback if conditional is true" do
        service_klass = Class.new(ApplicationService) do
          after :save, :after_save_callback, if: -> { true }
        end

        service = service_klass.new
        expect(service).to receive(:after_save_callback).and_return(true)
        expect(service.save(object)).to eq(true)
      end

      it 'should not invoke callback if conditional is false' do
        service_klass = Class.new(ApplicationService) do
          after :save, :after_save_callback, if: -> { false }
        end

        service = service_klass.new
        expect(service).not_to receive(:after_save_callback)
        expect(service.save(object)).to eq(true)
      end

      it 'should not invoke after save callbacks when save fails' do
        service_klass = Class.new(ApplicationService) do
          after :save, :after_save_callback
        end

        service = service_klass.new
        expect(object).to receive(:save).and_return(false)
        expect(service).not_to receive(:after_save_callback)
        expect(service.save(object)).to eq(false)
      end
    end
  end
end
