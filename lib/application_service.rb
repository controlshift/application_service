require 'active_support/all'

class ApplicationService

  include ActiveSupport::Callbacks
  define_callbacks :save, :create, :update, :destroy,
                   :terminator => "result == false"

  def initialize
  end


  def self.before(callback, *args)
    options = extract_callback_options(args, '!halted')

    args.each do |arg|
      set_callback callback, :before, arg, options
    end
  end

  def self.after(callback, *args)
    options = extract_callback_options(args, "!halted && value")

    args.each do |arg|
      set_callback callback, :after, arg, options
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

  def save!(obj)
    @obj = obj
    run_callbacks :save do
      if @obj.new_record?
        result = create!
      else
        result = update!
      end
      result
    end
  end

  def update_attributes(obj, params)
    @obj = obj
    @obj.assign_attributes(params)

    yield if block_given?

    run_callbacks :save do
      run_callbacks :update do
         @obj.save
      end
    end
  end

  def destroy(obj)
    @obj = obj
    run_callbacks :destroy do
      @obj.destroy
    end
  end

  private

  def create!
    run_callbacks :create do
      @obj.save!
    end
  end

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

  def update!
    run_callbacks :update do
      @obj.save!
    end
  end

  def self.extract_callback_options(args, default_if_option)
    options = args.last.is_a?(Hash) ? args.pop : {}
    if options && options.has_key?(:if)
      options[:if] = [options[:if], default_if_option]
    else
      options[:if] = default_if_option
    end

    options
  end

end
