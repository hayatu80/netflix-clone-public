class UsersController < ApplicationController
  before_filter :require_user, only: [:show]

  def show
    @user = User.find(params[:id])
  end

  def new
    redirect_to videos_path if current_user
    @user = User.new
  end

  def new_with_invitation_token
    invitation = Invitation.where(token: params[:token]).first
    if invitation
      @user = User.new(email: invitation.friend_email)
      @invitation_token = invitation.token
      render :new
    else
      redirect_to expired_token_path
    end
  end

  def create
    @user = User.new(params[:user])
    if @user.valid?
      Registration.new(@user).registration_process
      # handle_payment(@user)
      # if @charge.successful?
      #   @user.save
      #   session[:user_id] = @user.id
      #   handle_invitation
      #   AppMailer.notify_on_new_user(@user).deliver
      #   flash[:success] = "Successfully registered"
      #   redirect_to videos_path
      # else 
      #   flash[:error] = @charge.error_message
      #   render :new
      # end
    else
      flash[:error] = 'Cannot create an user, check the input and try again'
      render :new
    end
  end

  # def handle_payment(user)
  #   token = params[:stripeToken]
  #   @charge = StripeWrapper::Charge.create(
  #     :amount => 999,
  #     :card => token,
  #     :description => 'Myflix monthly service fee'
  #   )
  # end

  # def handle_invitation
  #   if params[:invitation_token].present?
  #     invitation = Invitation.where(token: params[:invitation_token]).first
  #     @user.follow(invitation.inviter)
  #     invitation.inviter.follow(@user)
  #     invitation.update_column(:token, nil)
  #   end 
  # end
end