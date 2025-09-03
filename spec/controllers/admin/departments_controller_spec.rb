require "rails_helper"

RSpec.describe Admin::DepartmentsController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:admin) { create(:user, :admin, active: true) }
  let(:department) { create(:department) }
  let(:deleted_department) { create(:department, :deleted) }

  let(:valid_params) do
    { department: { name: "New Department", description: "Description" } }
  end

  let(:invalid_params) do
    { department: { name: "", description: "Invalid" } }
  end

  before {
    sign_in admin
  }

  describe "GET #index" do
    let!(:department) { create(:department) }
    it "renders index with departments" do
      get :index
      expect(response).to render_template(:index)
      expect(assigns(:departments)).to be_present
    end
    context "when no departments found" do
      it "sets flash warning" do
        get :index, params: { q: { name_cont: "not_exist" } }
        expect(flash[:info]).to eq I18n.t("departments.index.table.no_result")
      end
    end
  end

  describe "GET #new" do
    it "assigns a new department" do
      get :new
      expect(assigns(:department)).to be_a_new(Department)
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates department and redirects" do
        expect {
          post :create, params: valid_params
        }.to change(Department, :count).by(1)

        expect(flash[:success]).to be_present
        expect(response).to redirect_to(admin_department_path(Department.last))
      end
    end

    context "with invalid params" do
      it "renders new with errors" do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
        expect(response.status).to eq(422)
      end
    end
  end

  describe "GET #edit" do
    it "renders edit" do
      get :edit, params: { id: department.id }
      expect(assigns(:department)).to eq(department)
      expect(response).to render_template(:edit)
    end
  end

  describe "PATCH #update" do
    context "with valid params" do
      it "updates department and redirects" do
        patch :update, params: { id: department.id, department: { name: "Updated" } }
        expect(department.reload.name).to eq("Updated")
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(admin_departments_path)
      end
    end

    context "with invalid params" do
      it "renders edit with errors" do
        patch :update, params: { id: department.id, department: { name: "" } }
        expect(response).to render_template(:edit)
        expect(response.status).to eq(422)
      end
    end
  end

  describe "GET #show" do
    it "renders show" do
      get :show, params: { id: department.id }
      expect(assigns(:department)).to eq(department)
      expect(response).to render_template(:show)
    end
  end

  describe "DELETE #destroy" do
    context "when the department is active" do
      context "and deletion is successful" do
        before do
          delete :destroy, params: { id: department.to_param, locale: :en }
        end

        it "soft-deletes the department" do
          expect(department.reload.deleted?).to be true
        end

        it "displays a success message" do
          expect(flash[:success]).to be_present
        end

        it "redirects to the department list page" do
          expect(response).to redirect_to(admin_departments_path)
        end
      end

      context "but deletion fails (e.g., due to before_destroy callback)" do
        before do
          allow_any_instance_of(Department).to receive(:destroy).and_return(false)
          delete :destroy, params: { id: department.to_param, locale: :en }
        end

        it "does not delete the department" do
          expect(department.reload.deleted?).to be false
        end

        it "displays a failure message" do
          expect(flash[:danger]).to be_present
        end

        it "redirects to the department list page" do
          expect(response).to redirect_to(admin_departments_path)
        end
      end
    end
  end
end
