class ProjectsController < ApplicationController

  before_filter :find_project, except: [:index, :new, :create]

  def index
    @projects = current_user.projects
  end

  def show
    @features = @project.features
  end

  def new; @project = Project.new; end

  def create
    @project = Project.new(project_params)
    @project.user_id = current_user.id
    if @project.save
      @project_user = ProjectUser.create!({user_id: current_user.id, project_id: @project.id, rights: 'owner'})
      respond_to do |format|
        format.html { redirect_to projects_path, notice: "Project successfully created! Please embed the AutoTest script code to your website and verify it to continue" }
      end
    else
      Rails.logger.debug(@project.inspect)
    end
  end

  def edit; end

  def update
    @project.attributes = params[:project]
    if @project.save
      respond_to do |format|
        format.html { redirect_to dashboard_path }
      end
    end
  end

  def destroy
    if @project.destroy
      respond_to do |format|
        format.html { redirect_to projects_path }
      end
    end
  end

  def remove_user
    @user = User.find(params[:user_id])
    @project_user = ProjectUser.where(project_id: @project.id, user_id: @user.id)
    if @project_user.destroy
      respond_to do |format|
        format.html { redirect_to edit_project_path(@project) }
      end
    end
  end

  def verify_script
    begin
      if @project.script_present?
        @project.update_attribute(:script_verified, true)
        flash[:notice] = "Script has been successfully verified! You can now add features and start recording scenarios"
      else
        flash[:notice] = "Could not find script"
      end
    rescue => e
      if e == SocketError
        flash[:notice] = "We were not able to find your website. Please make sure the project URL is correct."
      else
        flash[:notice] = "Something went wrong. Please try again soon."
      end
    end
    redirect_to :back
  end

  private

  def find_project
    @project = current_user.projects.find(params[:id] || params[:project_id])
  end

  def project_params
    params.require(:project).permit(:name, :url)
  end

end
