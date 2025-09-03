Department.update_all(manager_id: nil)
DailyReport.delete_all
User.delete_all
Department.delete_all

# Tạo phòng ban
departments = [
  Department.create!(name: "Phòng Kỹ thuật", description: "Xử lý các vấn đề kỹ thuật và bảo trì hệ thống"),
  Department.create!(name: "Phòng Kinh doanh", description: "Quản lý khách hàng và hoạt động kinh doanh"),
  Department.create!(name: "Phòng Hành chính", description: "Quản lý nhân sự, hành chính"),
  Department.create!(name: "Phòng IT", description: "Quản lý hệ thống mạng, phần mềm, phần cứng")
]

# Admin
User.create!(
  name: "Admin 1",
  email: "admin@gmail.com",
  role: :admin,
  password: "123456",
  active: true
)

5.times do |i|
  User.create!(
    name: "Nhân viên #{i + 1}",
    email: "user#{i + 1}@example.com",
    role: :user,
    password: "123456",
    department: departments.first
  )
end

manager = User.create!(
  name: "Ha Hong Son",
  email: "ha.hong.son@sun-asterisk.com",
  role: :manager,
  password: "123456",
  active: true
)

# Daily reports
employee1 = User.second
employee1.update active: true

report_dates = 10.days.ago.to_date.upto(Date.today).to_a.sample(10)

report_dates.each_with_index do |date, i|
  owner = employee1
  manager = manager

  next if DailyReport.exists?(owner: owner, report_date: date)

  DailyReport.create!(
    owner: owner,
    receiver: manager,
    report_date: date,
    status: DailyReport.statuses.keys.sample,
    planned_tasks: "Plan for day #{i + 1} ----------------------------------------------------",
    actual_tasks: "Did tasks #{i + 1} ----------------------------------------------------",
    incomplete_reason: i.even? ? "Blocked by issue" : nil,
    next_day_planned_tasks: "Next plan #{i + 2}----------------------------------------------------",
    manager_notes: i.odd? ? "Looks good." : nil,
    reviewed_at: Time.current - rand(1..5).days
  )
end

puts "✅ Seeded sample users and daily reports!"
