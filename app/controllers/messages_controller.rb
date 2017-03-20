class MessagesController < ApplicationController
  def index
    set_room
    @messages = @room.messages

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @messages }
    end
  end

  # POST /room/:id/messages
  def create
    set_room
    @message = @room.messages.build message_params
    @message.ip = request.remote_ip
    if current_user
      @message.username = current_user.username
    end

    if @message.save
      if !current_user && @message.username.present?
        sign_in!(@message.username)
      end
      ActionCable.server.broadcast("room_#{params[:room_id]}", html: render_message(@message))
    end

    respond_to do |format|
      format.html do
        if @message.persisted?
          redirect_to @room
        else
          flash[:error] = "Error: #{@room.errors.full_messages.to_sentence}"
          redirect_back fallback_location: root_path
        end
      end

      format.js
    end
  end

  private
  def set_room
    @room = Room.find params[:room_id]
  end

  def message_params
    params.require(:message).permit(:body, :username)
  end

  def render_message(message)
    ApplicationController.render partial: 'messages/message', locals: {message: message}
  end
end
