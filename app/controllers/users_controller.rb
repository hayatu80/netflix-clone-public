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
    if @user.save
      handle_payment(@user)
      handle_invitation
      AppMailer.notify_on_new_user(@user).deliver
      flash[:notice] = "Successfully registered"
      return login_path
    else
      render :new
    end
  end

  private

  def handle_payment(user)
    Stripe.api_key = ENV['STRIPE_API']
    token = params[:stripeToken]
    begin
      customer = Stripe::Customer.create(
        :card => token,
        :description => user.email
      )
      charge = Stripe::Charge.create(
        :amount => 999,
        :currency => "cad",
        :customer => customer.id,
        :card => token,
        :description => 'Myflix monthly service fee'
      )
    rescue Stripe::CardError => e
      user.destroy
      flash[:error] = e.message
      redirect_to new_user_path
    end
  end

  def handle_invitation
    if params[:invitation_token].present?
      invitation = Invitation.where(token: params[:invitation_token]).first
      @user.follow(invitation.inviter)
      invitation.inviter.follow(@user)
      invitation.update_column(:token, nil)
    end 
  end
end