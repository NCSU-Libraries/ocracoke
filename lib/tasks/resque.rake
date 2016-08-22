#lib/tasks/resque.rake

require 'resque/tasks'
#require 'resque/scheduler/tasks'

# I GOT THIS FROM Circa!

namespace :resque do

  task :work

  task :setup => :environment do
    Resque.before_fork = Proc.new do |job|
      ActiveRecord::Base.connection.disconnect!
    end
    Resque.after_fork = Proc.new do |job|
      ActiveRecord::Base.establish_connection
    end
  end

  desc "Restart running workers"
  task :restart_workers => :environment do
    Rake::Task['resque:stop_workers'].invoke
    Rake::Task['resque:start_workers'].invoke
  end

  desc "Quit running workers"
  task :stop_workers => :environment do
    stop_workers
  end

  desc "Start workers"
  task :start_workers => :environment do
    run_worker("*", 1)
  end



  def store_pids(pids, mode)
    pids_to_store = pids
    pids_to_store += read_pids if mode == :append

    # Make sure the pid file is writable.
    File.open(File.expand_path('tmp/pids/resque.pid', Rails.root), 'w') do |f|
      f <<  pids_to_store.join(',')
    end
  end

  def read_pids
    pid_file_path = File.expand_path('tmp/pids/resque.pid', Rails.root)
    return []  if ! File.exists?(pid_file_path)

    File.open(pid_file_path, 'r') do |f|
      f.read
    end.split(',').collect {|p| p.to_i }
  end

  def stop_workers
    pids = read_pids

    if pids.empty?
      puts "No workers to kill"
    else
      syscmd = "kill -s QUIT #{pids.join(' ')}"
      puts "$ #{syscmd}"
      `#{syscmd}`
      store_pids([], :write)
    end
  end

  # Start a worker with proper env vars and output redirection
  def run_worker(queue, count = 1)
    puts "Starting #{count} worker(s) with QUEUE: #{queue}"

    ##  make sure log/resque_err, log/resque_stdout are writable.
    ops = {:pgroup => true, :err => [(Rails.root + "log/resque_err").to_s, "a"],
                            :out => [(Rails.root + "log/resque_stdout").to_s, "a"]}
    env_vars = {"QUEUE" => queue.to_s, 'RAILS_ENV' => Rails.env.to_s}

    pids = []
    count.times do
      ## Using Kernel.spawn and Process.detach because regular system() call would
      ## cause the processes to quit when capistrano finishes
      pid = spawn(env_vars, "rake resque:work", ops)
      Process.detach(pid)
      pids << pid
    end

    store_pids(pids, :append)
  end
end
