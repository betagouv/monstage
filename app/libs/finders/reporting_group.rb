module Finders
  class ReportingGroup
    def groups_not_involved(is_public:)
      Group.select("groups.*, count(internship_offers.id) as group_internship_offers_count")
           .where(is_public: is_public)
           .joins(join_sources(is_public: is_public))
           .group('groups.id')
           .order('group_internship_offers_count')
    end


    private
    attr_reader :params
    def initialize(params:)
      @params = params
    end

    def join_sources(is_public:)
      internship_offers = InternshipOffer.arel_table
      groups = Group.arel_table

      conditions = internship_offers[:group_id].eq(groups[:id])
      conditions = conditions.and(internship_offers[:is_public]).eq(is_public)
      conditions = conditions.and(internship_offers[:department]).eq(department_param) if department_param

      groups.join(internship_offers, Arel::Nodes::OuterJoin)
            .on(conditions)
            .join_sources
    end

    def department_param
      params[:department]
    end
  end
end
