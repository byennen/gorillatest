class InvitationsController < Devise::InvitationsController

  before_filter :authenticate_user!, except: [:edit, :update]

  def create
    super
  end

  def edit
    super
  end

  def update
    update_resource_params = invitation_params
    binding.pry
    super
  end

  protected
  # modifying source code to use actionmailer
  def invite_resource
    resource_class.invite!(invite_params, current_inviter) do |u|
      u.skip_invitation = true
      @invited_user = u
    end
    User.send_invitation(@invited_user) if @invited_user.errors.empty?
    @invited_user
  end

  private

  def invitation_params
    params.require(:user).permit(:company_name, :phone, :password, :password_confirmation, :invitation_token)
  end

  def after_invite_path_for(resource)
    flash[:success] = "Invitation successfully sent!"
    new_invitation_path
  end

  def after_accept_path_for(resource)
    flash[:success] = "Thanks for signing up to AutoTest!"
    dashboard_path
  end
end
