class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def search
    # debugger
    @user = current_user

    @friends = current_user.friends

    @friends_srch = nil
    if params[:friend].present?
      @friends_srch = User.search(params[:friend])
      # debugger

      if !@friends_srch.empty?
        # debugger
        render "users/my_friends"
      else
        flash[:alert] = "No User Found"
        redirect_to my_friends_path
      end
    else
      flash[:alert] = "Please enter a user to search"
      redirect_to my_friends_path
    end
  end

  # private

  # def user_params
  #   params.require(:user).permit(:username, :email, :password, :admin, :bio, :avatar, :content, images: [])
  # end
end
