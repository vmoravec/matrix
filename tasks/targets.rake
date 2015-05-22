desc "List all targets"
task :targets do
  targets = Matrix.targets.map do |target|
    length = 10 - target.name.length
    "#{target.name}" + " "*length + "# #{target.desc}"
  end
  puts targets.join("\n")
end

namespace :target do

  def rescue_from_failure
    yield
  rescue => e
    puts "Failing..."
    abort e.message
  end

  namespace :qa2 do
    target = targets.find(:qa2)

    desc "Details about the qa2 target"
    task :info do
      puts target.inspect
    end

    desc "Test connection to qa2 gate by `ping` and `ssh`"
    task :test do
      puts "Testing ping to gate qa2..."
      ping = "ping -q -c 1 -W 5 #{target.gate.ip || target.gate.fqdn}"
      puts ping
      command.exec!(ping)

      puts "Testing ssh into gate qa2..."
      target.gate.exec!("echo 'This is a test'")

      puts "Connection test for gate to qa2 cluster has been successful"
    end
  end

  namespace :qa3 do
    target = targets.find(:qa3)

    desc "Details about the qa3 target"
    task :info do
      puts target.inspect
    end

    desc "Test connection to qa3 gate by `ping` and `ssh`"
    task :test do
      puts "Testing ping to gate qa3..."
      ping = "ping -q -c 1 -W 5 #{target.gate.ip || target.gate.fqdn}"
      puts ping
      command.exec!(ping)

      puts "Testing ssh into gate qa3..."
      target.gate.exec!("echo 'This is a test'")

      puts "Connection test for gate to qa3 cluster has been successful"
    end
  end

  namespace :virtual do
    target = targets.find(:virtual)

    desc "Details about the virtual target"
    task :info do
      puts target.inspect
    end

    if target.gate
      desc "Test connection to the gate for virtual target"
      task :test do
      end
    end

    desc "Details about the virtual target"
    task :test do
      puts "Testing ping to admin node..."
      ping = "ping -q -c 1 -W 5 #{target.admin_node.ip || target.admin_node.fqdn}"
      puts "#{ping}"
      rescue_from_failure do
        command.exec!(ping)
      end

      puts "Testing ssh into the admin node"
      rescue_from_failure do
        target.admin_node.exec!("echo 'This is a test'")
      end
      puts "Connection test for admin node in target 'virtual' has been successful"
    end

  end
end
