# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "🌱 Seeding database..."

# Clear existing data
AppointmentRequest.destroy_all
Service.destroy_all
Nutritionist.destroy_all

puts "Creating nutritionists..."

# Nutritionists in Braga
braga_nutritionists = [
  { name: "Dra. Ana Silva", location: "Braga" },
  { name: "Dr. João Santos", location: "Braga" },
  { name: "Dra. Maria Oliveira", location: "Braga" }
]

# Nutritionists in Porto
porto_nutritionists = [
  { name: "Dra. Sofia Costa", location: "Porto" },
  { name: "Dr. Miguel Ferreira", location: "Porto" },
  { name: "Dra. Catarina Sousa", location: "Porto" }
]

# Nutritionists in Lisboa
lisboa_nutritionists = [
  { name: "Dra. Beatriz Rodrigues", location: "Lisboa" },
  { name: "Dr. Tiago Almeida", location: "Lisboa" }
]

# Nutritionists in other cities
other_nutritionists = [
  { name: "Dra. Inês Martins", location: "Coimbra" },
  { name: "Dr. Pedro Carvalho", location: "Aveiro" },
  { name: "Dra. Rita Gomes", location: "Faro" },
  { name: "Dr. Carlos Pereira", location: "Viseu" }
]

all_nutritionists_data = braga_nutritionists + porto_nutritionists + lisboa_nutritionists + other_nutritionists
nutritionists = all_nutritionists_data.map { |data| Nutritionist.create!(data) }

puts "Created #{nutritionists.count} nutritionists"

# Service names in Portuguese
service_types = [
  { name: "Consulta de Nutrição Geral", price_range: (40..60) },
  { name: "Consulta de Nutrição Desportiva", price_range: (50..70) },
  { name: "Plano Alimentar Personalizado", price_range: (60..90) },
  { name: "Consulta de Emagrecimento", price_range: (45..65) },
  { name: "Consulta de Nutrição Infantil", price_range: (40..55) },
  { name: "Avaliação Corporal Completa", price_range: (35..50) },
  { name: "Consulta de Nutrição Vegetariana", price_range: (45..60) },
  { name: "Acompanhamento Nutricional Mensal", price_range: (80..120) },
  { name: "Consulta de Nutrição para Diabetes", price_range: (50..70) },
  { name: "Consulta Online", price_range: (30..45) }
]

puts "Creating services..."

services_count = 0
nutritionists.each do |nutritionist|
  # Each nutritionist gets 3-5 random services
  service_types.sample(rand(3..5)).each do |service_type|
    Service.create!(
      nutritionist: nutritionist,
      name: service_type[:name],
      price: rand(service_type[:price_range])
    )
    services_count += 1
  end
end

puts "Created #{services_count} services"

puts "Creating appointment requests..."

# Sample guest data
guests = [
  { name: "Paulo Mendes", email: "paulo.mendes@example.com" },
  { name: "Joana Ribeiro", email: "joana.ribeiro@example.com" },
  { name: "André Lopes", email: "andre.lopes@example.com" },
  { name: "Mariana Costa", email: "mariana.costa@example.com" },
  { name: "Ricardo Fernandes", email: "ricardo.fernandes@example.com" },
  { name: "Luísa Carvalho", email: "luisa.carvalho@example.com" },
  { name: "Francisco Alves", email: "francisco.alves@example.com" },
  { name: "Teresa Pinto", email: "teresa.pinto@example.com" }
]

# Create various appointment requests with different statuses
appointment_requests = []

# Pending requests for testing the nutritionist page
nutritionists.first(5).each_with_index do |nutritionist, index|
  service = nutritionist.services.sample
  guest = guests[index]

  appointment_requests << AppointmentRequest.create!(
    nutritionist: nutritionist,
    service: service,
    guest_name: guest[:name],
    guest_email: guest[:email],
    desired_date: Date.today + (index + 1).days,
    desired_time: Time.zone.parse("#{10 + index}:00"),
    status: "pending"
  )
end

# More pending requests at different times
3.times do |i|
  nutritionist = nutritionists.sample
  service = nutritionist.services.sample
  guest = guests.sample

  appointment_requests << AppointmentRequest.create!(
    nutritionist: nutritionist,
    service: service,
    guest_name: guest[:name],
    guest_email: guest[:email],
    desired_date: Date.today + rand(1..7).days,
    desired_time: Time.zone.parse("#{[ 9, 11, 14, 15, 16 ].sample}:#{[ 0, 30 ].sample}"),
    status: "pending"
  )
end

# Accepted requests
2.times do
  nutritionist = nutritionists.sample
  service = nutritionist.services.sample
  guest = guests.sample

  appointment_requests << AppointmentRequest.create!(
    nutritionist: nutritionist,
    service: service,
    guest_name: guest[:name],
    guest_email: guest[:email],
    desired_date: Date.today - rand(1..7).days,
    desired_time: Time.zone.parse("#{[ 10, 11, 14, 15 ].sample}:00"),
    status: "accepted"
  )
end

# Rejected requests
2.times do
  nutritionist = nutritionists.sample
  service = nutritionist.services.sample
  guest = guests.sample

  appointment_requests << AppointmentRequest.create!(
    nutritionist: nutritionist,
    service: service,
    guest_name: guest[:name],
    guest_email: guest[:email],
    desired_date: Date.today - rand(1..5).days,
    desired_time: Time.zone.parse("#{[ 9, 10, 11 ].sample}:30"),
    status: "rejected"
  )
end

# Invalidated requests
appointment_requests << AppointmentRequest.create!(
  nutritionist: nutritionists.first,
  service: nutritionists.first.services.first,
  guest_name: guests.last[:name],
  guest_email: guests.last[:email],
  desired_date: Date.today + 3.days,
  desired_time: Time.zone.parse("14:00"),
  status: "invalidated"
)

puts "Created #{appointment_requests.count} appointment requests"

# Summary
puts "\n✅ Seeding complete!"
puts "=" * 50
puts "📊 Summary:"
puts "  Nutritionists: #{Nutritionist.count}"
puts "  Services: #{Service.count}"
puts "  Appointment Requests: #{AppointmentRequest.count}"
puts "    - Pending: #{AppointmentRequest.pending.count}"
puts "    - Accepted: #{AppointmentRequest.where(status: 'accepted').count}"
puts "    - Rejected: #{AppointmentRequest.where(status: 'rejected').count}"
puts "    - Invalidated: #{AppointmentRequest.where(status: 'invalidated').count}"
puts "\n🏙️  Cities: #{Nutritionist.distinct.pluck(:location).join(', ')}"
puts "=" * 50
