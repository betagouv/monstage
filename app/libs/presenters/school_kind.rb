# frozen_string_literal: true

module Presenters
  class SchoolKind
    def to_s
      case kind
      when 'rep_plus' then 'REP+'
      when 'rep' then 'REP'
      when 'qpv', 'qpv_proche' then 'QPV'
      else '?'
      end
    end

    private

    attr_reader :kind
    def initialize(kind:)
      @kind = kind
    end
  end
end
