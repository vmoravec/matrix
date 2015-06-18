namespace :admin_domain do
  desc "Prepare admin domain for crowbar setup"
  task :prepare do
    attempts = 1
    begin
      admin_domain.command.test_ssh!
    rescue
      attempts += 1
      sleep 5
      retry unless attempts == 5
    end

    admin_domain.exec! "rm -f qa_crowbarsetup.sh"
    admin_domain.exec! "wget --no-check-certificate " +
    "https://raw.github.com/SUSE-Cloud/automation/master/scripts/qa_crowbarsetup.sh"
  end
end
