require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/string/inflections'

module Artdeco

  module DecoratorMethods

    def decorate model, *decorator_classes
      return nil if model.nil?
      return model.map{|m| decorate(m,*decorator_classes)} if model.respond_to?(:map)
      decorator_classes = @decorator_classes || default_decorator_class(model) if decorator_classes.empty?
      [decorator_classes].flatten.each{|dc|model.extend dc}
      h = self.h
      model.define_singleton_method(:h){h}
      model.extend DecoratorMethods
      model
    end
    
    private
    def default_decorator_class model 
      @_decorator_classes_cache ||= {} 
      [@_decorator_classes_cache.fetch(model.class){decorator_class_for model}].compact
    end

    def decorator_class_for model
      clazz = model.class
      while clazz != Object 
        result = ("::#{clazz}Decorator".constantize rescue nil)
        return result if result
        clazz = clazz.superclass
      end
      nil
    end

  end

  module ClassMethods
    def decorate model, *args
      Decorator.new(*args).decorate(model)
    end
  end

  class Decorator

    include DecoratorMethods

    attr_reader :params, :view_context
    alias_method :h, :view_context
    
    # Args may be either the params hash of the request
    # or an object which responds to :params and optionally to :view_context, e.g. a controller instance
    # If a view_context is given it will be accessible in various blocks by calling :h
    def initialize *args
      opts = args.extract_options!
      
      @decorator_classes = ([opts.delete(:decorators)] + [opts.delete(:decorator)]).flatten.compact
      @decorator_classes = nil if @decorator_classes.empty? # required for #decorate

      case args.size
      when 0
        @view_context = opts.delete :view_context 
        @params = opts.delete(:params){opts}
      when 1
        arg = args.first
        @view_context = arg.respond_to?(:view_context) ? arg.view_context : nil

        if arg.respond_to? :params
          @params = arg.params.symbolize_keys.merge(opts)
        else
          raise ArgumentError, 'argument must respond_to :params'
        end
      else
        raise ArgumentError, 'too many arguments' if args.size > 1
      end
    end
 
    # evaluate data (string or proc)
    # if model is provided it will accessible in evaluated data
    def eval data, model = nil
      case data
      when Proc
        (model ? model : self).instance_exec(&data)
      else
        data
      end
    end

  end

  self.extend ClassMethods
end
