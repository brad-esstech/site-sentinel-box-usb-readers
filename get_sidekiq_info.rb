require_relative 'worker.rb'

default_queue = Sidekiq::Queue.new
ss = Sidekiq::ScheduledSet.new
stats = Sidekiq::Stats.new
rs = Sidekiq::RetrySet.new
ds = Sidekiq::DeadSet.new

jobs_in_queue = default_queue.size
jobs_processed = stats.processed
jobs_failed = stats.failed
queue_stats = stats.queues
jobs_scheduled = ss.size
jobs_retry = rs.size
jobs_dead = ds.size

puts "Number of jobs in default queue: #{jobs_in_queue}"
puts "Scheduled jobs: #{jobs_scheduled}"
puts "Failed jobs: #{jobs_failed}"
puts "Retry queue count: #{jobs_retry}"
puts "Dead queue count: #{jobs_dead}"