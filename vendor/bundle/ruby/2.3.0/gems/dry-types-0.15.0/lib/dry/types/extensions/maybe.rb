require 'dry/monads/maybe'
require 'dry/types/decorator'

module Dry
  module Types
    class Maybe
      include Type
      include Dry::Equalizer(:type, :options, inspect: false)
      include Decorator
      include Builder
      include Dry::Monads::Maybe::Mixin

      # @param [Dry::Monads::Maybe, Object] input
      # @return [Dry::Monads::Maybe]
      def call(input = Undefined)
        case input
        when Dry::Monads::Maybe
          input
        when Undefined
          None()
        else
          Maybe(type[input])
        end
      end
      alias_method :[], :call

      # @param [Object] input
      # @return [Result::Success]
      def try(input = Undefined)
        res = if input.equal?(Undefined)
                None()
              else
                Maybe(type[input])
              end

        Result::Success.new(res)
      end

      # @return [true]
      def default?
        true
      end

      # @param [Object] value
      # @see Dry::Types::Builder#default
      # @raise [ArgumentError] if nil provided as default value
      def default(value)
        if value.nil?
          raise ArgumentError, "nil cannot be used as a default of a maybe type"
        else
          super
        end
      end
    end

    module Builder
      # @return [Maybe]
      def maybe
        Maybe.new(Types['strict.nil'] | self)
      end
    end

    class Printer
      MAPPING[Maybe] = :visit_maybe

      def visit_maybe(maybe)
        visit(maybe.type) do |type|
          yield "Maybe<#{ type }>"
        end
      end
    end

    # Register non-coercible maybe types
    NON_NIL.each_key do |name|
      register("maybe.strict.#{name}", self["strict.#{name}"].maybe)
    end

    # Register coercible maybe types
    COERCIBLE.each_key do |name|
      register("maybe.coercible.#{name}", self["coercible.#{name}"].maybe)
    end
  end
end
