Department.update_all(manager_id: nil)
User.delete_all
Department.delete_all

departments = [
  Department.create!(name: "Phòng Kỹ thuật", description: "Xử lý các vấn đề kỹ thuật và bảo trì hệ thống"),
  Department.create!(name: "Phòng Kinh doanh", description: "Quản lý khách hàng và hoạt động kinh doanh"),
  Department.create!(name: "Phòng Hành chính", description: "Quản lý nhân sự, hành chính"),
  Department.create!(name: "Phòng IT", description: "Quản lý hệ thống mạng, phần mềm, phần cứng")
]

10.times do |i|
  User.create!(
    name: "Nhân viên #{i + 1}",
    email: "user#{i + 1}@example.com",
    role: 0,
    password: "123456",
    department: departments.sample
  )
end

User.create!(
  name: "Admin 1",
  email: "admin@gmail.com",
  role: 2,
  password: "123456"
)

manager = User.create!(
  name: "Quản lý 1",
  email: "manager1@example.com",
  role: 1,
  password: "123456",
  department: departments.first
)

manager.managed_departments << departments[0..2]

new_user = User.create!(
  name: "New user 1",
  email: "newuser@gmail.com",
  role: 0,
  password: "123456"
)

# Daily reports
user1 = User.first
user2 = User.second

report_dates = 10.days.ago.to_date.upto(Date.today).to_a.sample(10)

report_dates.each_with_index do |date, i|
  owner = [user1, user2].sample

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
