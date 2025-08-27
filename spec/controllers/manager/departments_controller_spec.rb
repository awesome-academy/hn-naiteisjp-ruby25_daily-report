require "rails_helper"

RSpec.describe Manager::DepartmentsController, type: :controller do
  describe "GET #show" do
    # --- Context 1: Logged in as a Manager ---
    context "when logged in as a manager" do
      # --- Sub-context 1.1: Manager HAS a department ---
      context "and is assigned to a department" do
        let(:manager) { create(:user, :manager_with_department, active: true) }
        let(:department) { manager.department }

        # Create users within the same department for testing counts and lists
        let!(:active_staff) { create_list(:user, 2, department: department, active: true) }
        let!(:inactive_staff) { create(:user, department: department, active: false) }
        # This user should not be included in the paginated list by default
        let!(:other_dept_staff) { create(:user, :user_with_department, active: true) }

        before do
          sign_in manager
          # The :id is required for routing but the controller uses current_user.department
          get :show, params: { id: department.to_param }
        end

        it "assigns the correct department to @department" do
          expect(assigns(:department)).to eq(department)
        end

        it "assigns the correct count of active, non-manager users to @active_users_count" do
          expect(assigns(:active_users_count)).to eq(2)
        end

        it "assigns a Ransack search object to @q" do
          expect(assigns(:q)).to be_a(Ransack::Search)
        end

        it "assigns the correct staff members to @users" do
          expect(assigns(:users)).to match_array(active_staff)
          expect(assigns(:users)).not_to include(inactive_staff)
        end

        it "renders the 'show' template" do
          expect(response).to render_template(:show)
        end

        it "returns a successful response" do
          expect(response).to have_http_status(:success)
        end
      end

      # --- Sub-context 1.2: Manager does NOT have a department ---
      context "and is not assigned to a department" do
        let(:manager_no_dept) { create(:user, :manager, department: nil, active: true) }

        before do
          sign_in manager_no_dept
          # A dummy :id is needed for the route to resolve
          get :show, params: { id: 1 }
        end

        it "assigns @department as nil" do
          expect(assigns(:department)).to be_nil
        end

        it "does not assign other instance variables due to the guard clause" do
          expect(assigns(:active_users_count)).to be_nil
          expect(assigns(:q)).to be_nil
          expect(assigns(:users)).to be_nil
        end

        it "redirect to root page" do
          expect(response).to redirect_to(root_url)
        end
      end
    end

    # --- Context 2: Logged in as a NON-Manager ---
    context "when logged in as a non-manager user" do
      let(:user) { create(:user, active: true) }
      let(:department) { create(:department) } # Dummy department for the route

      before do
        sign_in user
        get :show, params: { id: department.to_param }
      end

      it "redirects to the root url" do
        expect(response).to redirect_to(root_url)
      end

      it "shows a warning flash message" do
        expect(flash[:warning]).to eq(I18n.t("users.errors.no_right"))
      end
    end
  end
end
