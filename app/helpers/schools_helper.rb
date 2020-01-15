module SchoolsHelper
  def humanize_school_kind(kind)
    case kind
    when 'rep_plus' then 'REP+'
    when 'rep' then 'REP'
    when 'qpv', 'qpv_proche' then 'QPV'
    else '?'
    end
  end
end
