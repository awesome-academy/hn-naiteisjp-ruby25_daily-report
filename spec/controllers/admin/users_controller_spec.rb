require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do
  let(:admin) { create(:user, :admin, active: true) }
  let!(:department) { create(:department, :without_manager) }

  let(:valid_attributes) do
    {
      name: "New User",
      email: "newuser@example.com",
      role: "user",
      active: true,
      department_id: department.id,
      password: "password123"
    }
  end

  let(:invalid_attributes) { { name: "Invalid User", email: "" } }

  before do
    sign_in admin
  end

  describe "GET #index" do
    before do
      create_list(:user, 5)
      get :index
    end

    it "assigns a list of users (excluding admin) to @users" do
      expect(assigns(:users).count).to eq(5)
      expect(assigns(:users)).not_to include(admin)
    end

    it "renders the 'index' template" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    let(:user) { create(:user) }

    before do
      get :show, params: { id: user.to_param }
    end

    it "assigns the correct user to @user" do
      expect(assigns(:user)).to eq(user)
    end

    it "renders the 'show' template" do
      expect(response).to render_template(:show)
    end
  end

  describe "GET #new" do
    before do
      get :new
    end

    it "assigns a new user to @user" do
      expect(assigns(:user)).to be_a_new(User)
    end

    it "generates a random password for @generated_password" do
      expect(assigns(:generated_password)).not_to be_blank
    end

    it "assigns all departments to @departments" do
      expect(assigns(:departments)).to eq([department])
    end

    it "renders the 'new' template" do
      expect(response).to render_template(:new)
    end
  end

  describe "GET #edit" do
    let(:user) { create(:user) }

    before do
      get :edit, params: { id: user.to_param }
    end

    it "assigns the correct user to @user" do
      expect(assigns(:user)).to eq(user)
    end

    it "assigns all departments to @departments" do
      expect(assigns(:departments)).to eq([department])
    end

    it "renders the 'edit' template" do
      expect(response).to render_template(:edit)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new User" do
        expect do
          post :create, params: { user: valid_attributes }
        end.to change(User, :count).by(1)
      end

      it "sends a welcome email" do
        allow(UserMailer).to receive_message_chain(:welcome_email, :deliver_now)
        post :create, params: { user: valid_attributes }
        expect(UserMailer).to have_received(:welcome_email)
      end

      it "updates manager_id for department if the new user is a manager" do
        manager_attributes = valid_attributes.merge(role: "manager")
        post :create, params: { user: manager_attributes }
        new_manager = User.find_by(email: manager_attributes[:email])
        expect(department.reload.manager_id).to eq(new_manager.id)
      end

      it "redirects to the user list page" do
        post :create, params: { user: valid_attributes }
        expect(response).to redirect_to(admin_users_path)
      end
    end

    context "with invalid params" do
      it "does not create a new user" do
        expect do
          post :create, params: { user: invalid_attributes }
        end.not_to change(User, :count)
      end

      it "re-renders the 'new' template with unprocessable_entity status" do
        post :create, params: { user: invalid_attributes }
        expect(response).to render_template(:new)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH #update" do
    let!(:user_to_update) { create(:user, department: nil) }
    let(:new_attributes) { { name: "Updated Name", department_id: department.id } }

    context "with valid params" do
      before do
        patch :update, params: { id: user_to_update.to_param, user: new_attributes }
      end

      it "updates the user successfully" do
        user_to_update.reload
        expect(user_to_update.name).to eq("Updated Name")
        expect(user_to_update.department_id).to eq(department.id)
      end

      it "redirects to the user list page" do
        expect(response).to redirect_to(admin_users_path)
      end
    end

    context "with invalid params" do
      before do
        patch :update, params: { id: user_to_update.to_param, user: invalid_attributes }
      end

      it "does not update the user" do
        user_to_update.reload
        expect(user_to_update.name).not_to eq("Invalid User")
      end

      it "re-renders the 'edit' template with unprocessable_entity status" do
        expect(response).to render_template(:edit)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:user_to_deactivate) { create(:user, active: true) }

    it "changes the user's 'active' status to false (soft delete)" do
      delete :destroy, params: { id: user_to_deactivate.to_param }
      user_to_deactivate.reload
      expect(user_to_deactivate.active).to be(false)
    end

    it "redirects to the user list page" do
      delete :destroy, params: { id: user_to_deactivate.to_param }
      expect(response).to redirect_to(admin_users_path)
    end

    context "when the update fails" do
      before do
        allow_any_instance_of(User).to receive(:update).and_return(false)
        delete :destroy, params: { id: user_to_deactivate.to_param }
      end

      it "does not change the user's 'active' status" do
        user_to_deactivate.reload
        expect(user_to_deactivate.active).to be(true)
      end

      it "displays flash danger" do
        expect(flash[:danger]).to be_present
      end
    end
  end
end
