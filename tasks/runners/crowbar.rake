namespace :crowbar do
  namespace :batch do
    desc "Deploy nova barclamp proposal"
    task :nova do
      crowbar.batch(build: :nova)
    end
  end
end

