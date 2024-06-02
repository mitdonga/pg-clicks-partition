require 'pg'
require 'faker'

# Database connection parameters
DB_HOST = 'localhost'
DB_NAME = 'cuelinks_test'
DB_USER = 'postgres'
DB_PASSWORD = 'postgres'
TABLE_NAME = 'clicks_partitioned_view'
# TABLE_NAME = 'clicks'

# Connect to the PostgreSQL database
conn = PG.connect(
  host: DB_HOST,
  dbname: DB_NAME,
  user: DB_USER,
  password: DB_PASSWORD
)

# Method to generate a single fake record
def generate_fake_record
  {
    ip_address: Faker::Internet.ip_v4_address,
    country_code: Faker::Address.country_code,
    campaign_id: rand(1..100),
    user_id: rand(1..100),
    channel_id: rand(1..100),
    traffic_source: ["Facebook", "Twitter", "Search Engine"].sample,
    subid1: "222222",
    subid2: Faker::Lorem.word,
    subid3: Faker::Lorem.word,
    created_at: Faker::Time.backward(days: 10)
  }
end

# Generate and insert 10,000 fake records
conn.transaction do |conn|
  10_000.times do
    record = generate_fake_record
    conn.exec_params(
      "INSERT INTO #{TABLE_NAME} (ip_address, country_code, campaign_id, user_id, channel_id, traffic_source, subid1, subid2, subid3, created_at) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)",
      [record[:ip_address], record[:country_code], record[:campaign_id], record[:user_id], record[:channel_id], record[:traffic_source], record[:subid1], record[:subid2], record[:subid3], record[:created_at]]
    )
  end
end

puts "10,000 fake records have been inserted into the table #{TABLE_NAME}."