class ClassRoomsController < ApplicationController
  rescue_from(CanCan::AccessDenied) do |error|
    redirect_to(root_path,
                flash: { danger: "Vous n'êtes pas autorisé à gérer les classes" })
  end

  def create
    authorize! :create, ClassRoom
    current_user.school.class_rooms.create(class_rooms_params)
  end

  def new
    authorize! :new, ClassRoom
    @school = current_user.school
  end

  private
  def class_rooms_params
    params.require(:class_room).permit(:name)
  end
end
