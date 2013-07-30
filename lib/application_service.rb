require 'active_support/all'

class ApplicationService

  include ActiveSupport::Callbacks
  define_callbacks :save, :create, :update,
                   :terminator => "result == false"

  def initialize
  end


  def self.before(callback, *args)
    args.each do |arg|
      set_callback callback, :before, arg, :if => "!halted"
    end
  end

  def self.after(callback, *args)
    args.each do |arg|
      set_callback callback, :after, arg, :if => "!halted && value"
    end
  end

  def current_object
    @obj
  end

  def current_object=(obj)
    @obj = obj
  end

  def save(obj)
    @obj = obj
    run_callbacks :save do
      if @obj.new_record?
        result = create
      else
        result = update
      end
      result
    end
  end

  def update_attributes(obj, params)
    @obj = obj
    @obj.assign_attributes(params)
    run_callbacks :save do
      run_callbacks :update do
         @obj.save
      end
    end
  end

  private

  def create
    run_callbacks :create do
      @obj.save
    end
  end

  def update
    run_callbacks :update do
      @obj.save
    end
  end


end