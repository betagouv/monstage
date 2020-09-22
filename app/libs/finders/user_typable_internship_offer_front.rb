# frozen_string_literal: true

module Finders
  # build base query to request internship offers per user.type
  class UserTypableInternshipOfferFront < UserTypableInternshipOffer
    def base_query
      send(MappingUserTypeWithScope.fetch(user.type))
        .group(:id)
        .page(params[:page])
    end
    
    MappingUserTypeWithScope = {
      Users::Operator.name => :visitor_query,
      Users::Visitor.name => :visitor_query,
      Users::SchoolManagement.name => :school_members_query,
      Users::Student.name => :school_members_query,
      Users::Employer.name => :employer_query,
      Users::Statistician.name => :statistician_query,
      Users::God.name => :god_query
    }.freeze

    attr_reader :user, :params

    def initialize(user:, params:)
      @user = user
      @params = params
    end
  end
end
