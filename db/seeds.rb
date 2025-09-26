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
Status.find_or_create_by!(name: "Attempted", tag: "attempted")
Status.find_or_create_by!(name: "Call Back Today", tag: "cbt")
Status.find_or_create_by!(name: "Interested", tag: "hot")
Status.find_or_create_by!(name: "Dead", tag: "dead")

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


