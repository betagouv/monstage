# frozen_string_literal: true

module Presenters
  class Address
    def to_s
      [
        instance.street,
        instance.zipcode,
        instance.city
      ].compact.join("\n")
    end

    def full_address
      [
        instance.street,
        instance.zipcode,
        instance.city
      ].compact.join(" ")
    end

    private

    attr_reader :instance

    def initialize(instance:)
      @instance = instance
    end
  end
end
