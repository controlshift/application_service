require 'active_support/all'

class ApplicationService

  include ActiveSupport::Callbacks
  define_callbacks :save, :create, :update, :destroy, {terminator: ->(target, result) { result.call == false }, skip_after_callbacks_if_terminated: true}

  def initialize
  end

  def self.before(callback, *args)
    options = extract_callback_options(args)

    args.each do |arg|
      set_callback callback, :before, arg, options
      if options.fetch(:skip_on_admin_save, false)
        skip_callback callback, :before, arg, if: -> { @on_admin_save }
      end
    end
  end

  def self.after(callback, *args)
    options = extract_callback_options(args)

    conditional = ActiveSupport::Callbacks::Conditionals::Value.new { |v|
      v != false
    }
    options[:if] = Array(options[:if]) << conditional

    args.each do |arg|
      set_callback callback, :after, arg, options
      if options.fetch(:skip_on_admin_save, false)
        skip_callback callback, :after, arg, if: -> { @on_admin_save }
      end
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

  def admin_save(obj)
    @obj = obj

    @on_admin_save = true
    save_method = @obj.respond_to?(:admin_save) ? :admin_save : :save
    run_callbacks :save do
      if @obj.new_record?
        result = create(save_method)
      else
        result = update(save_method)
      end
      result
    end
  ensure
    @on_admin_save = false
  end

  private

  def create!(save_method=:save!)
    run_callbacks :create do
      @obj.send(save_method)
    end
  end

  def create(save_method=:save)
    run_callbacks :create do
      @obj.send(save_method)
    end
  end

  def update(save_method=:save)
    run_callbacks :update do
      @obj.send(save_method)
    end
  end

  def update!(save_method=:save!)
    run_callbacks :update do
      @obj.send(save_method)
    end
  end

  private

  def self.extract_callback_options(args)
    options = args.last.is_a?(Hash) ? args.pop : {}

    options
  end

end
