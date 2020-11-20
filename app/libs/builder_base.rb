class BuilderBase
  def authorize(*vargs)
    return nil if ability.can?(*vargs)

    raise CanCan::AccessDenied
  end
end
