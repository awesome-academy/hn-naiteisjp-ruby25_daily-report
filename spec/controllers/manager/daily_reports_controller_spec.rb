require "rails_helper"

RSpec.describe Manager::DailyReportsController, type: :controller do
  let!(:department) { create(:department) }
  let(:manager) { create(:user, :manager, department: department, active: true) }
  let(:staff_member) { create(:user, :user, department: department) }
  let(:other_staff) { create(:user, :user, department: create(:department)) }

  let!(:staff_report) do
    create(:daily_report, owner: staff_member, receiver: manager,
                          manager_notes: nil, status: :pending)
  end
  let!(:other_report) { create(:daily_report, owner: other_staff) }

  context "when logged in as a manager" do
    before do
      sign_in manager
    end

    describe "GET #index" do
      before do
        get :index
      end

      it "assigns the correct staff members to @staff_members" do
        expect(assigns(:staff_members)).to match_array([staff_member])
      end

      it "assigns the correct daily reports of staff members to @daily_reports" do
        expect(assigns(:daily_reports)).to match_array([staff_report])
        expect(assigns(:daily_reports)).not_to include(other_report)
      end

      it "renders the 'index' template" do
        expect(response).to render_template(:index)
      end
    end

    describe "GET #edit" do
      before do
        get :edit, params: { id: staff_report.to_param }
      end

      it "assigns the correct daily report to @daily_report" do
        expect(assigns(:daily_report)).to eq(staff_report)
      end

      it "renders the 'edit' template" do
        expect(response).to render_template(:edit)
      end
    end

    describe "PATCH #update" do
      context "with valid parameters (adding manager notes)" do
        let(:valid_params) do
          { id: staff_report.to_param, daily_report: { manager_notes: "Good work!" } }
        end

        before do
          patch :update, params: valid_params
        end

        it "successfully updates manager_notes" do
          staff_report.reload
          expect(staff_report.manager_notes).to eq("Good work!")
        end

        it "updates status to 'commented'" do
          staff_report.reload
          expect(staff_report.status).to eq("commented")
        end

        it "updates reviewed_at" do
          staff_report.reload
          expect(staff_report.reviewed_at).to be_present
        end

        it "redirects to the daily reports list page" do
          expect(response).to redirect_to(manager_daily_reports_path)
        end
      end

      context "with valid parameters (marking as read, no notes)" do
        let(:read_params) do
          { id: staff_report.to_param, daily_report: { manager_notes: "" } }
        end

        before do
          staff_report.update(manager_notes: "Initial note")
          patch :update, params: read_params
        end

        it "updates status to 'read' when old note is removed" do
          staff_report.reload
          expect(staff_report.status).to eq("read")
        end
      end

      context "with invalid parameters" do
        before do
          allow_any_instance_of(DailyReport).to receive(:update).and_return(false)
          patch :update, params: { id: staff_report.to_param, daily_report: { manager_notes: "Note" } }
        end

        it "does not update the daily report" do
          staff_report.reload
          expect(staff_report.manager_notes).to be_nil
        end

        it "re-renders the 'edit' template" do
          expect(response).to render_template(:edit)
        end
      end
    end
  end

  context "when logged in with a non-manager role" do
    let(:user) { create(:user, active: true) }

    before do
      sign_in user
    end

    it "blocks access to #index and redirects" do
      get :index
      expect(response).to redirect_to(root_url)
      expect(flash[:warning]).to be_present
    end

    it "blocks access to #edit and redirects" do
      get :edit, params: { id: staff_report.to_param }
      expect(response).to redirect_to(root_url)
      expect(flash[:warning]).to be_present
    end

    it "blocks access to #update and redirects" do
      patch :update, params: { id: staff_report.to_param, daily_report: { manager_notes: "Test" } }
      expect(response).to redirect_to(root_url)
      expect(flash[:warning]).to be_present
    end
  end
end
