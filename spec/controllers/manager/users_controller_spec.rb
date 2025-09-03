require "rails_helper"

RSpec.describe Manager::UsersController, type: :controller do
  let(:manager) { create(:user, :manager_with_department, active: true) }
  let(:department) { manager.department }
  let(:staff_in_dept) { create(:user, department: department, active: true) }
  let!(:unassigned_user) { create(:user, active: true) }

  context "when logged in as a manager" do
    before do
      sign_in manager
    end

    describe "GET #new" do
      context "when there are unassigned users" do
        before do
          get :new
        end

        it "assigns a list of unassigned users to @available_users" do
          expect(assigns(:available_users)).to eq([unassigned_user])
        end

        it "renders the 'new' template" do
          expect(response).to render_template(:new)
        end
      end

      context "when there are no unassigned users" do
        before do
          unassigned_user.update(department: create(:department))
          get :new
        end

        it "redirects to the department details page" do
          expect(response).to redirect_to(manager_department_path(department))
        end

        it "displays a warning message" do
          expect(flash[:warning]).to be_present
        end
      end
    end

    describe "POST #create" do
      context "with a valid user_id" do
        it "assigns the user to the manager's department" do
          post :create, params: { user_id: unassigned_user.id }
          unassigned_user.reload
          expect(unassigned_user.department).to eq(department)
        end

        it "redirects to the department details page" do
          post :create, params: { user_id: unassigned_user.id }
          expect(response).to redirect_to(manager_department_path(department))
        end
      end

      context "with an invalid user_id" do
        before do
          post :create, params: { user_id: "invalid_id" }
        end

        it "does not change the user's department" do
          unassigned_user.reload
          expect(unassigned_user.department).to be_nil
        end

        it "redirects to the new user page" do
          expect(response).to redirect_to(new_manager_user_path)
        end

        it "displays a danger message" do
          expect(flash[:danger]).to be_present
        end
      end
    end

    describe "GET #show" do
      before do
        get :show, params: { id: staff_in_dept.to_param }
      end

      it "assigns the correct user to @user" do
        expect(assigns(:user)).to eq(staff_in_dept)
      end

      it "renders the 'show' template" do
        expect(response).to render_template(:show)
      end
    end

    describe "DELETE #destroy" do
      context "when successfully removing user from department" do
        it "updates the user's department_id to nil" do
          delete :destroy, params: { id: staff_in_dept.to_param }
          staff_in_dept.reload
          expect(staff_in_dept.department_id).to be_nil
        end

        it "redirects to the department details page" do
          delete :destroy, params: { id: staff_in_dept.to_param }
          expect(response).to redirect_to(manager_department_path(department))
        end
      end

      context "when removal fails" do
        before do
          allow_any_instance_of(User).to receive(:update).and_return(false)
          delete :destroy, params: { id: staff_in_dept.to_param }
        end

        it "displays a danger message" do
          expect(flash[:danger]).to be_present
        end

        it "still redirects to the department details page" do
          expect(response).to redirect_to(manager_department_path(department))
        end
      end
    end
  end

  context "when logged in with a non-manager role" do
    let(:user) { create(:user, active: true) }

    before do
      sign_in user
    end

    it "blocks access to #new and redirects" do
      get :new
      expect(response).to redirect_to(root_url)
    end

    it "blocks access to #create and redirects" do
      post :create, params: { user_id: unassigned_user.id }
      expect(response).to redirect_to(root_url)
    end
  end
end
