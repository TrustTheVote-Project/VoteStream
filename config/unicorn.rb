# Set the working application directory
# working_directory "/path/to/your/app"
working_directory "/home/ec2-user/votestream/current"

# Unicorn PID file location
# pid "/path/to/pids/unicorn.pid"
pid "/home/ec2-user/votestream/current/tmp/pids/unicorn.pid"

# Path to logs
# stderr_path "/path/to/log/unicorn.log"
# stdout_path "/path/to/log/unicorn.log"
stderr_path "/home/ec2-user/votestream/current/log/unicorn.log"
stdout_path "/home/ec2-user/votestream/current/log/unicorn.log"

# Unicorn socket
listen "/home/ec2-user/votestream/current/tmp/sockets/unicorn.[app name].sock"
listen "/home/ec2-user/votestream/current/tmp/sockets/unicorn.myapp.sock"

# Number of processes
# worker_processes 4
worker_processes 2

# Time-out
timeout 30