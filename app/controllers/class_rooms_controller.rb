class ClassRoomsController < ApplicationController
  rescue_from(CanCan::AccessDenied) do |error|
    redirect_to(root_path,
                flash: { danger: "Vous n'êtes pas autorisé à gérer les classes" })
  end

  def create
    authorize! :create, ClassRoom
    @school = current_user.school
    @class_room = @school.class_rooms.new(class_rooms_params)
    @class_room.save!
    redirect_to new_class_room_path
  rescue ActiveRecord::RecordInvalid => error
    render :new,
           flash: { danger: "Vous n'êtes pas autorisé à créer une annonce" }
  end

  def edit
    authorize! :edit, ClassRoom
    @school = current_user.school
    @class_room = @school.class_rooms.find(params[:id])
  end

  def update
    authorize! :update, ClassRoom
    @school = current_user.school
    @class_room = @school.class_rooms.find(params[:id])
    @class_room.update!(class_rooms_params)
    redirect_to new_class_room_path
  rescue ActiveRecord::RecordInvalid => error
    render :edit,
           flash: { danger: "Vous n'êtes pas autorisé à créer une annonce" }
  end

  def new
    authorize! :new, ClassRoom
    @school = current_user.school
    @class_room = @school.class_rooms.new
  end

  private
  def class_rooms_params
    params.require(:class_room).permit(:name)
  end
end
