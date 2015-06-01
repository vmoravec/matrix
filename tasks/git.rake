namespace :git do
  # This is not git related but it updates the cct gem from git repo
  namespace :cct do
    desc "Update the gem from cct repository"
    task :pull do
      system "bundle update"
    end
  end

  namespace :auto do
    def automation_repo
      @path ||= matrix.config["vendor_dir"] + "/automation"
    end

    def checkout_target
      ENV['branch'] || matrix.config['git']['automation']['branch'] || 'master'
    end

    desc "Remove the old repo and clone it again"
    task :reload do
      rm_rf(automation_repo)
      invoke_task("git:automation:clone")
    end

    desc "Fetch the remote"
    task :fetch do
      puts "Fetching from url '#{matrix.config['git']['automation']['url']}'"
      chdir(automation_repo) do
        system "git fetch origin"
      end
    end

    desc "Create a clone of automation repository"
    task :clone do
      puts "Cloning from url '#{matrix.config['git']['automation']['url']}'"
      chdir(matrix.config['vendor_dir']) do
        system "git clone git@#{matrix.config['git']['automation']['url']}"
      end
    end

    desc "Update the automation code from upstream repo"
    task :pull do
      chdir(automation_repo) do
        system "git pull origin #{checkout_target}"
      end
    end

    desc "Checkout the prefered branch"
    task :checkout do
      chdir(automation_repo) do
        system "git checkout #{checkout_target}"
      end
    end

    desc "Show git log"
    task :log do
      chdir(automation_repo) do
        system "git log"
      end
    end
  end
end
