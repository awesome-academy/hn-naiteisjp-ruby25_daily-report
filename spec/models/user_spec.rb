require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "Associations" do
    it { is_expected.to belong_to(:department).optional }
    it { is_expected.to have_many(:sent_reports).class_name("DailyReport").with_foreign_key(:owner_id).dependent(:destroy) }
    it { is_expected.to have_many(:received_reports).class_name("DailyReport").with_foreign_key(:receiver_id).dependent(:nullify) }
    it { is_expected.to have_one_attached(:avatar) }
  end

  describe "Validations" do
    context "when validating name" do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_length_of(:name).is_at_most(Settings.MAX_LENGTH_USERNAME) }
    end

    context "when validating email" do
      it { is_expected.to validate_presence_of(:email) }
      it { is_expected.to validate_length_of(:email).is_at_most(Settings.MAX_LENGTH_EMAIL) }
    end
    context "when a user already exists to test uniqueness" do
      it { create(:user); is_expected.to validate_uniqueness_of(:email).case_insensitive.with_message(I18n.t("users.errors.email_already_exists")) }
      it { is_expected.to allow_value("user@example.com").for(:email) }
      it { is_expected.not_to allow_value("userexample.com").for(:email).with_message("is invalid") }
    end

    context "when validating avatar" do
      it "is valid with a jpeg" do
        user.avatar.attach(io: File.open(Rails.root.join("spec/fixtures/files/valid_image.jpeg")), filename: "test_image.jpg", content_type: "image/jpeg")
        expect(user).to be_valid
      end

      it "is invalid with a pdf" do
        user.avatar.attach(io: File.open(Rails.root.join("spec/fixtures/files/test_pdf.pdf")), filename: "test_pdf.pdf", content_type: "application/pdf")
        expect(user).not_to be_valid
        expect(user.errors[:avatar]).to include(I18n.t("users.profile.avatar_type_error"))
      end
    end

    context "custom validation 'one_manager_per_department'" do
      let(:department) { create(:department) }
      let!(:existing_manager) { create(:user, :manager, department: department) }

      it "does not allow creating a new manager for that department" do
        new_manager = build(:user, :manager, department: department)
        expect(new_manager).not_to be_valid
        expect(new_manager.errors[:role]).to include(I18n.t("users.errors.one_manager_per_department"))
      end

      it "allows updating the current manager" do
        existing_manager.name = "New Name"
        expect(existing_manager).to be_valid
      end
    end
  end

  describe "Enums" do
    it { is_expected.to define_enum_for(:role).with_values(Settings.user_role.to_h) }
  end

  describe "Delegations" do
    it { is_expected.to delegate_method(:name).to(:department).with_prefix(true) }
    it { is_expected.to delegate_method(:manager).to(:department).allow_nil }
    it { is_expected.to delegate_method(:name).to(:manager).with_prefix(true).allow_nil }
  end

  describe "Scopes" do
    let!(:department) { create(:department, :without_manager) }
    let!(:admin) { create(:user, :admin, active: true) }
    let!(:manager) { create(:user, :manager, department: department, active: true) }
    let!(:active_user) { create(:user, department: department, active: true) }
    let!(:inactive_user) { create(:user, department: department, active: false) }
    let!(:unassigned_user) { create(:user, department: nil, role: :user) }

    it ".not_admin returns all non-admin users" do
      expect(User.not_admin).to match_array([manager, active_user, inactive_user, unassigned_user])
    end

    it ".not_manager returns all non-manager users" do
      expect(User.not_manager).to match_array([admin, active_user, inactive_user, unassigned_user])
    end

    it ".active returns all active users" do
      expect(User.active).to match_array([admin, manager, active_user])
    end

    it ".inactive returns all inactive users" do
      expect(User.inactive).to contain_exactly(inactive_user, unassigned_user)
    end

    it ".managed_by(manager) returns users managed by the manager" do
      expect(User.managed_by(manager)).to contain_exactly(active_user, inactive_user)
    end

    it ".unassigned_users returns users without a department" do
      expect(User.unassigned_users).to contain_exactly(unassigned_user)
    end

    it ".get_staff_members(manager) returns staff members in the department (excluding the manager)" do
      expect(User.get_staff_members(manager)).to match_array([active_user, inactive_user])
    end
  end

  describe "Instance Methods" do
    context "#active_for_authentication?" do
      it "returns true if the user is active" do
        user = build(:user, active: true)
        expect(user.active_for_authentication?).to be true
      end

      it "returns false if the user is inactive" do
        user = build(:user, active: false)
        expect(user.active_for_authentication?).to be false
      end
    end

    context "#inactive_message" do
      it "returns :inactive_account if the user is inactive" do
        user = build(:user, active: false)
        expect(user.inactive_message).to eq(:inactive_account)
      end

      it "returns Devise's default message if the user is active" do
        user = build(:user, active: true)
        expect(user.inactive_message).to eq(:inactive)
      end
    end
  end
end
