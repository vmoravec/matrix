desc "Install dependencies"
task :install do
  sh "bundle install"
  invoke_task("install:automation:clone")
end

desc "Update dependencies"
task :update do
  sh "bundle update"
  invoke_task("install:automation:pull")
end


namespace :install do
  namespace :automation do
    def automation_repo
      @path ||= matrix.config["vendor_dir"] + "/automation"
    end

    def checkout_target
      ENV['branch'] || matrix.config['git']['automation']['branch'] || 'master'
    end

    # Remove the old repo and clone it again
    task :reload do
      rm_rf(automation_repo)
      invoke_task("install:automation:clone")
    end

    # Fetch the remote
    task :fetch do
      puts "Fetching from url '#{matrix.config['git']['automation']['url']}'"
      chdir(automation_repo) do
        system "git fetch origin"
      end
    end

    # Create a clone of automation repository
    task :clone do
      puts "Cloning from url '#{matrix.config['git']['automation']['url']}'"
      chdir(matrix.config['vendor_dir']) do
        system "git clone git@#{matrix.config['git']['automation']['url']}"
      end
    end

    # Update the automation code from upstream repo
    task :pull do
      chdir(automation_repo) do
        system "git pull origin #{checkout_target}"
      end
    end

    # Checkout the prefered branch
    task :checkout do
      chdir(automation_repo) do
        system "git checkout #{checkout_target}"
      end
    end

    # Show git log
    task :log do
      chdir(automation_repo) do
        system "git log"
      end
    end
  end
end
