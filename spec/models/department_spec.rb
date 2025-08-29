require "rails_helper"

RSpec.describe Department, type: :model do
  let(:department) { FactoryBot.create(:department) }
  describe "associations" do
    it "belongs to manager" do
      association = described_class.reflect_on_association(:manager)
      expect(association.macro).to eq(:belongs_to)
      expect(association.class_name).to eq(User.name)
      expect(association.options[:optional]).to be true
    end

    it "has many users" do
      association = described_class.reflect_on_association(:users)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:nullify)
    end

    it "has many daily reports through users" do
      association = described_class.reflect_on_association(:daily_reports)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:users)
      expect(association.options[:source]).to eq(:sent_reports)
    end

    context "manager association behavior" do
      let(:manager) { FactoryBot.create(:user, :manager) }

      it "can have a manager" do
        department.manager = manager
        expect(department.manager).to eq(manager)
      end

      it "can be created without a manager" do
        department_without_manager = FactoryBot.create(:department, manager: nil)
        expect(department_without_manager.manager).to be_nil
      end
    end

    context "users association behavior" do
      let!(:user1) { FactoryBot.create(:user, department: department) }
      let!(:user2) { FactoryBot.create(:user, department: department) }

      it "has many users" do
        expect(department.users).to include(user1, user2)
      end

      it "nullifies users' department_id when department is destroyed" do
        department_id = department.id
        department.destroy
        expect(User.find(user1.id).department_id).to be_nil
        expect(User.find(user2.id).department_id).to be_nil
      end
    end

    context "daily_reports association behavior" do
      let(:user_with_reports) { FactoryBot.create(:user, department: department) }
      let!(:daily_report1) { FactoryBot.create(:daily_report, owner: user_with_reports) }
      let!(:daily_report2) { FactoryBot.create(:daily_report, owner: user_with_reports) }

      it "has many daily reports through users" do
        expect(department.daily_reports).to include(daily_report1, daily_report2)
      end
    end
  end

  describe "validations" do
    subject { FactoryBot.build(:department) }

    it "validates presence of name" do
      subject.name = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("can't be blank")
    end

    it "validates uniqueness of name (case-insensitive)" do
      FactoryBot.create(:department, name: "Existing Department")
      subject.name = "existing department"
      expect(subject).not_to be_valid
      expect(subject.errors[:name]).to include("has already been taken")
    end

    it "validates presence of description" do
      subject.description = nil
      expect(subject).not_to be_valid
      expect(subject.errors[:description]).to include("can't be blank")
    end

    it "validates length of description" do
      subject.description = "short"
      expect(subject).not_to be_valid
      expect(subject.errors[:description]).to include("is too short (minimum is #{Settings.MIN_LENGTH_DESCRIPTION_10} characters)")

      subject.description = "a" * Settings.MIN_LENGTH_DESCRIPTION_10
      expect(subject).to be_valid
    end
  end

  describe "constants" do
    it "defines DEPARTMENT_PARAMS" do
      expect(described_class::DEPARTMENT_PARAMS).to eq(%w(name description deleted_at))
    end
  end

  describe "scopes" do
    let!(:department1) { FactoryBot.create(:department, name: "Z Department", created_at: 2.days.ago) }
    let!(:department2) { FactoryBot.create(:department, name: "A Department", created_at: 1.day.ago) }
    let!(:department3) { FactoryBot.create(:department, name: "B Department", created_at: 3.days.ago) }

    describe ".order_by_latest" do
      it "orders departments by created_at in descending order" do
        expect(described_class.order_by_latest).to eq([department2, department1, department3])
      end
    end

    describe ".order_by_name" do
      it "orders departments by name in descending order" do
        expect(described_class.order_by_name).to eq([department1, department3, department2])
      end
    end

    describe ".search_by_name" do
      context "when query is present" do
        it "returns departments matching the query" do
          expect(described_class.search_by_name("Z Department")).to include(department1)
          expect(described_class.search_by_name("Z Department")).not_to include(department2, department3)
        end

        it "returns departments matching a partial query" do
          expect(described_class.search_by_name("Department")).to include(department1, department2, department3)
        end

        it "returns departments matching case-insensitive query" do
          expect(described_class.search_by_name("z department")).to include(department1)
        end
      end

      context "when query is blank" do
        it "returns all departments" do
          expect(described_class.search_by_name("")).to eq([department1, department2, department3].sort_by(&:id)) # Assuming default order by id
          expect(described_class.search_by_name(nil)).to eq([department1, department2, department3].sort_by(&:id))
        end
      end
    end

    describe ".with_department_id" do
      it "returns the department with the given ID" do
        expect(described_class.with_department_id(department1.id)).to eq([department1])
      end

      it "returns an empty relation if no department matches the ID" do
        expect(described_class.with_department_id(0)).to be_empty
      end
    end
  end
end
