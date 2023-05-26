class UsersController < ApplicationController
  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /users or /users.json
  def index
    authorize User
    @users = policy_scope(User)
  end

  # GET /users/1 or /users/1.json
  def show
    @user = policy_scope(User).find(params[:id])
    authorize @user, policy_class: UserPolicy
    @other_groups = Group.where(tenant_id: params[:tenant_id])
      .where.not(group_type: 'USER')
      .where.not(
        id:
          Group.includes(:users).where(users: {id: @user.id}),
      )
  end

  # GET /users/new
  def new
    @user = Current.tenant.users.new
    authorize @user
  end

  # GET /users/1/edit
  def edit
    authorize @user
  end

  # POST /users or /users.json
  def create
    @user = Current.tenant.users.new(user_params)
    authorize @user

    respond_to do |format|
      if @user.save
        format.html { redirect_to Current.tenant, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    authorize @user
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to Current.tenant, notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    authorize @user
    @user.destroy

    respond_to do |format|
      format.html { redirect_to Current.tenant, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = policy_scope(User).find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:name, :email, :user_type)
    end
end