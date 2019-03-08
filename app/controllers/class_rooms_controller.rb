class ClassRoomsController < ApplicationController
  before_action :set_school
  before_action :authenticate_user!
  def create
    authorize! :create, ClassRoom
    @school = current_user.school
    @class_room = @school.class_rooms.new(class_rooms_params)
    @class_room.save!
    redirect_to account_path
  rescue ActiveRecord::RecordInvalid => error
    render :new
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
    redirect_to account_path
  rescue ActiveRecord::RecordInvalid => error
    render :edit
  end

  def new
    authorize! :new, ClassRoom
    @school = current_user.school
    @class_room = @school.class_rooms.new
  end

  private
  def set_school
    @school = School.find(params.require(:school_id))
  end
  def class_rooms_params
    params.require(:class_room).permit(:name)
  end
end
