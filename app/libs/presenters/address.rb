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

    def organisation_full_address
      return "" if instance.organisation.nil?

      [
        instance.organisation.street,
        instance.organisation.zipcode,
        instance.organisation.city
      ].compact.join(" ")
    end

    private

    attr_reader :instance

    def initialize(instance:)
      @instance = instance
    end
  end
end
