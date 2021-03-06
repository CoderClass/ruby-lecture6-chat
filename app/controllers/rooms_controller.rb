class RoomsController < ApplicationController
  def show
    @room = Room.find params[:id]
    @messages = @room.messages.order('created_at DESC')
  end

  def create
    @room = Room.new room_params

    if @room.save
      if (message = @room.messages.first) && message.username.present?
        message.update_column :ip, request.remote_ip
        sign_in!(message.username)
      end

      redirect_to @room
    else
      flash[:error] = "Error: #{@room.errors.full_messages.to_sentence}"
      redirect_back fallback_location: root_path
    end
  end

  private

  def room_params
    params.require(:room).permit(:name, :messages_attributes => [:username, :body])
  end
end
