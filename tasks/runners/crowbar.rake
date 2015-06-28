namespace :crowbar do
  desc "List machines"
  task :list_machines do
    crowbar.list_nodes.each_with_index do |machine, i|
      puts "#{i + 1}. #{machine}"
    end
  end

  desc "All nodes discovered"
  task :wait_all_discovered do
    crowbar.wait_all_discovered
  end

  namespace :batch do
    @proposals = %w(
      pacemaker
      database
      rabbitmq
      keystone
      swift
      ceph
      glance
      cinder
      neutron
      nova
      nova_dashboard
      ceilometer
      heat
      trove
      tempest
    )

    namespace :build do |build|
      @proposals.each do |proposal|

        desc "Deploy proposal #{proposal}"
        task proposal do |task|
          story.finalize!
          crowbar.batch(build: proposal)
        end

      end

      desc "Deploy all proposals"
      task :all do
        @proposals.each do |proposal|

          Rake::Task[build[proposal]].invoke

        end
      end

    end
  end
end

