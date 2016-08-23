class Epsadmin::AdminsController < ApplicationController

  before_filter :check_admin, :check_not_merchant
  def index
    @epsadmin_users = User.where(:role.ne => "merchant").order("created_at DESC") #(.ne) mongo condition != not working
    respond_to do |format|
      format.html
      format.json { render json: @epsadmin_users }
    end
  end

  def show
    @epsadmin_user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @epsadmin_user }
    end
  end

  def new
    @epsadmin_user = User.new
    respond_to do |format|
      format.html
      format.json { render json: @epsadmin_user }
    end
  end

  def edit
    @epsadmin_user = User.find(params[:id])
  end

  def create
    @epsadmin_user = User.new(user_params)

    respond_to do |format|
      if @epsadmin_user.save
        format.html { redirect_to epsadmin_admins_path, notice: 'User was successfully created.' }
        format.json { render json: epsadmin_admins_path, status: :created, location: @epsadmin_user }
        UserMailer.welcome_admin(@epsadmin_user).deliver
      else
        format.html { render action: "new" }
        format.json { render json: @epsadmin_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @epsadmin_user = User.find(params[:id])

    respond_to do |format|
      if @epsadmin_user.update_attributes(user_params)
        format.html { redirect_to epsadmin_admin_path, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: epsadmin_admin_path.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @epsadmin_user = User.find(params[:id])
    @epsadmin_user.destroy
    respond_to do |format|
      format.html { redirect_to epsadmin_admins_path , notice: 'User was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def update_user_status
    @update_user_status = User.find(params[:uid])
    if params[:stat] == "Disable"
      @update_user_status.update_attributes(:disabled => true)
    else
      @update_user_status.update_attributes(:disabled => false)
    end
    respond_to do |format|
      format.html { redirect_to epsadmin_admins_path, notice: 'Status was successfully updated.'}
      format.json { head :no_content }
    end
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @epsadmin_user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:full_name,:email,:password, :password_confirmation ,:role)
    end
  
end
