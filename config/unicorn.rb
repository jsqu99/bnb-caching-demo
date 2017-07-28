# config/unicorn.rb
worker_processes (ENV['WEB_CONCURRENCY'] || 3).to_i
timeout (ENV['UNICORN_TIMEOUT'] || 27).to_i
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  if ENV['BB_SEGMENT_IO_SECRET'].present?
    defined?(Analytics) and Analytics.init(secret: ENV['BB_SEGMENT_IO_SECRET'])
  end

  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end
