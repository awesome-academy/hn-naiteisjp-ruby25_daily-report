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
        get :index, params: { query: "not_exist" }
        expect(flash[:warning]).to eq I18n.t("departments.index.table.no_result")
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
    context "when not deleted" do
      it "destroys and redirects" do
        delete :destroy, params: { id: department.id }
        expect(flash[:success]).to be_present
        expect(response).to redirect_to(admin_departments_path)
      end
    end

    context "when already deleted" do
      it "does not destroy and redirects with danger" do
        delete :destroy, params: { id: deleted_department.id }
        expect(flash[:danger]).to be_present
        expect(response).to redirect_to(admin_departments_path)
      end
    end
  end
end
