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

    desc "Test connection to the virtual target"
    task :test do
      if target.gate
        print "Testing ping to the gate at #{target.gate.ip || target.gate.fqdn}: "
        ping = "ping -q -c 1 -W 5 #{target.gate.ip || target.gate.fqdn}"
        print "#{ping}"
        rescue_from_failure do
          command.exec!(ping)
        end
        puts "    Success!"

        print "Testing ping to admin node through gate at #{target.gate.ip || target.gate.fqdn}: "
        ping = "ping -q -c 1 -W 5 #{target.admin_node.ip || target.admin_node.fqdn}"
        print "#{ping}"
        rescue_from_failure do
          target.gate.exec!(ping)
        end
        puts "    Success!"

        print "Testing ssh into the gate..."
        rescue_from_failure do
          target.gate.exec!("echo 'This is a test'")
        end
        puts "    Success!"
      else
        desc "Details about the virtual target"
        task :test do
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
          puts "Connection test for admin node in target 'virtual' has been successful"
        end
      end
    end
  end
end
