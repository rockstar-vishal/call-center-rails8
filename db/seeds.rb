# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create Roles
puts "Creating roles..."
sysad_role = Role.find_or_create_by!(name: "System Administrator", tag: "sysad")
admin_role = Role.find_or_create_by!(name: "Administrator", tag: "admin")
manager_role = Role.find_or_create_by!(name: "Manager", tag: "manager")
executive_role = Role.find_or_create_by!(name: "Executive", tag: "executive")

# Create Statuses
puts "Creating statuses..."
Status.find_or_create_by!(name: "New", tag: "new")
Status.find_or_create_by!(name: "Contacted", tag: "contacted")
Status.find_or_create_by!(name: "Interested", tag: "interested")
Status.find_or_create_by!(name: "Not Interested", tag: "not_interested")
Status.find_or_create_by!(name: "Follow Up", tag: "follow_up")
Status.find_or_create_by!(name: "Converted", tag: "converted")
Status.find_or_create_by!(name: "Lost", tag: "lost")

# Create Sources
puts "Creating sources..."
Source.find_or_create_by!(name: "Website", tag: "website")
Source.find_or_create_by!(name: "Social Media", tag: "social_media")
Source.find_or_create_by!(name: "Referral", tag: "referral")
Source.find_or_create_by!(name: "Cold Call", tag: "cold_call")
Source.find_or_create_by!(name: "Advertisement", tag: "advertisement")

# Create System Company for SysAdmin
puts "Creating system company..."
system_company = Company.find_or_create_by!(
  name: "System Administration",
  domain: "system.local",
  lead_limit: nil
)

# Create SysAdmin User
puts "Creating sysadmin user..."
sysadmin = User.find_or_create_by!(email: "admin@system.local") do |user|
  user.name = "System Administrator"
  user.password = "password123"
  user.phone = "1234567890"
  user.company = system_company
  user.role = sysad_role
end

# Create Sample Companies
puts "Creating sample companies..."
company1 = Company.find_or_create_by!(
  name: "TechCorp Solutions",
  domain: "techcorp.com",
  lead_limit: 1000
)

company2 = Company.find_or_create_by!(
  name: "Marketing Pro",
  domain: "marketingpro.com", 
  lead_limit: 500
)

# Create Sample Users for Company 1
puts "Creating sample users..."
admin1 = User.find_or_create_by!(email: "admin@techcorp.com") do |user|
  user.name = "John Admin"
  user.password = "password123"
  user.phone = "9876543210"
  user.company = company1
  user.role = admin_role
end

manager1 = User.find_or_create_by!(email: "manager@techcorp.com") do |user|
  user.name = "Jane Manager"
  user.password = "password123"
  user.phone = "9876543211"
  user.company = company1
  user.role = manager_role
end

executive1 = User.find_or_create_by!(email: "exec@techcorp.com") do |user|
  user.name = "Bob Executive"
  user.password = "password123"
  user.phone = "9876543212"
  user.company = company1
  user.role = executive_role
end

# Create Sample Users for Company 2
admin2 = User.find_or_create_by!(email: "admin@marketingpro.com") do |user|
  user.name = "Alice Admin"
  user.password = "password123"
  user.phone = "9876543213"
  user.company = company2
  user.role = admin_role
end

# Create Sample Projects
puts "Creating sample projects..."
project1 = Project.find_or_create_by!(
  name: "Web Development Services",
  company: company1
)

project2 = Project.find_or_create_by!(
  name: "Mobile App Development",
  company: company1
)

project3 = Project.find_or_create_by!(
  name: "Digital Marketing Campaign",
  company: company2
)

# Create Sample Leads
puts "Creating sample leads..."
new_status = Status.find_by(tag: "new")
contacted_status = Status.find_by(tag: "contacted")
interested_status = Status.find_by(tag: "interested")

Lead.find_or_create_by!(
  email: "lead1@example.com",
  company: company1
) do |lead|
  lead.name = "Michael Johnson"
  lead.phone = "5551234567"
  lead.project = project1
  lead.status = new_status
  lead.user = executive1
  lead.comment = "Interested in web development services"
  lead.ncd = 2.days.from_now
end

Lead.find_or_create_by!(
  email: "lead2@example.com",
  company: company1
) do |lead|
  lead.name = "Sarah Wilson"
  lead.phone = "5551234568"
  lead.project = project2
  lead.status = contacted_status
  lead.user = executive1
  lead.comment = "Looking for mobile app development"
  lead.ncd = 1.day.from_now
end

Lead.find_or_create_by!(
  email: "lead3@example.com",
  company: company2
) do |lead|
  lead.name = "David Brown"
  lead.phone = "5551234569"
  lead.project = project3
  lead.status = interested_status
  lead.user = admin2
  lead.comment = "Wants to discuss digital marketing options"
  lead.ncd = 3.days.from_now
end

puts "Seed data created successfully!"
puts ""
puts "Login credentials:"
puts "SysAdmin: admin@system.local / password123"
puts "Company Admin (TechCorp): admin@techcorp.com / password123"
puts "Company Manager (TechCorp): manager@techcorp.com / password123"
puts "Company Executive (TechCorp): exec@techcorp.com / password123"
puts "Company Admin (Marketing Pro): admin@marketingpro.com / password123"