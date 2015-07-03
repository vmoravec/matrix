desc "List all targets"
task :targets do
  puts Matrix.targets.all
end

namespace :target do

  def rescue_from_failure
    yield
  rescue => e
    puts "   Failed."
    abort e.message
  end

  def detect_target
    target = targets.find(ENV["target"])
    abort "Missing target. Provide a target by `target=TARGET`" unless target

    target
  end

  desc "Details about the target"
  task :info do
    puts detect_target.inspect
  end

  desc "Test connection to target gate by `ping` and `ssh`"
  task :test do
    target = detect_target
    if target.gate && !target.gate.localhost?
      remote = Matrix::RemoteCommand.new(
        ip: target.gate.ip || target.gate.fqdn,
        user: target.gate.user
      )
      puts "Testing ping to gate #{target.name} ..."
      ping = "ping -q -c 1 -W 5 #{target.gate.ip || target.gate.fqdn}"
      print ping
      rescue_from_failure do
        command.exec!(ping)
      end
      puts "    Success!"

      print "Testing ssh into gate #{target.name} ..."
      rescue_from_failure do
        remote.exec!("echo 'This is a test'")
      end
      puts "    Success!"

      puts "Connection test for gate to #{target.name} hardware has been successful"
    else
      print "Testing ping to admin node: "
      ping = "ping -q -c 1 -W 5 #{target.admin_node.ip || target.admin_node.fqdn}"
      print "#{ping}"
      rescue_from_failure do
        command.exec!(ping)
      end
      puts "    Success!"

      print "Testing ssh into the admin node"
      rescue_from_failure do
        target.admin_node.exec!("echo 'This is a test'")
      end
      puts "    Success!"
      puts "Connection test for admin node in target #{target.name} has been successful"
    end
  end
end
