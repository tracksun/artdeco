require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/string/inflections'

module Artdeco

  module DecoratorMethods

    def decorate model, *decorator_modules
      return nil if model.nil?

      return model.map{|m| decorate(m,*decorator_modules)} if model.respond_to?(:map)

      decorator_modules = @decorator_modules || default_decorator_module(model) if decorator_modules.empty?
      [decorator_modules].flatten.each do |decorator_module|
        model.extend decorator_module
        if decorator_module.const_defined?(:ClassMethods)
          model.class.extend(decorator_module.const_get(:ClassMethods))
        end
      end

      h = self.h
      model.define_singleton_method(:h){h}
      model.extend DecoratorMethods

      model
    end

    private
    def default_decorator_module model
      @_decorator_modules_cache ||= {}
      [@_decorator_modules_cache.fetch(model.class){decorator_module_for model}].compact
    end

    def decorator_module_for model
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

      @decorator_modules = ([opts.delete(:decorators)] + [opts.delete(:decorator)]).flatten.compact
      @decorator_modules = nil if @decorator_modules.empty? # required for #decorate

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
