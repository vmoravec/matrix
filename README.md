![alt tag](https://raw.github.com/vmoravec/matrix/master/matrix-gh.png)

# matrix

Story runner for cloud testsuite

## Quick start

  1.  Check [system dependencies](#dependencies)
  2.  `git clone git@github.com:vmoravec/matrix`
  3.  `cd matrix && bundle install`
  4.  `rake git:automation:clone`
  4.  `rake h`
  5.  `rake story:default`

## Installation

  Make sure you have installed all [dependencies](#dependencies)

  After you have cloned the repository, install the required rubygems:

     bundle install

  All rubygems will be installed into the directory `vendor/bundle` within the repo.

  This is the default setup, if you use one of Ruby version managers like `RVM`,
  you might want to create a new gemset and override the bundle config
  in `.bundle/config` with:

     bundle install --system


## Dependencies

    zypper in rubygem-bundler ruby-devel
    zypper in gcc make lvm2 libvirt

  List of required rubygems can be found in file `matrix.gemspec` and in `Gemfile`.
  Additionally, you need to run `rake git:automation:clone` to git required scripts
  for SUSE cloud installation.


## Usage

     bundle exec rake help

  To get rid of the annoying `rake` command prefixing with `bundle exec`, having done

     alias rake="bundle exec rake"

  might be useful. The command `bundle exec` takes care about locating and loading
  the correct rubygems from the pre-configured path as set by `.bundle/config`.

  If you get an error like

    rake aborted!
    LoadError: cannot load such file -- cct
    /home/path/to/code/matrix/Rakefile:6:in `<top (required)>'

  the rubygems installed in path `vendor/bundle` are not visible to `rake`.

## Useful commands

  Get some help:

     rake help
     rake h
     rake -T
     rake -T keyword

  More specific help:

     rake config
     rake config:main
     rake features
     rake stories

  Story specific help:

     rake story:default:runners
     rake story:default:features

  Run a story:

     rake story:default

  Most of the runners' output goes currently into the log file in `log/matrix.log`, 
  use `tail -f log/matrix.log`. 

  Run unit tests for code inside `lib` directory:

     rake spec

## What is a story?

  A story is a pre-defined SUSE Cloud deployment with tests executed at some
  specific checkpoints. These checkpoints are reached after the execution of `runners`
  has finished.

## What is a runner?

  Runners are commands that drive the deployment/installation of cloud.
  Currently these are commands from `mkcloud` script available in 
  [SUSE-cloud automation repository](https://github.com/SUSE-Cloud/automation/blob/master/scripts/mkcloud).

  In theory a runner could be any other command once it's available as a `rake` task within
  this repository (look into the directory `tasks/`).

## What is a feature?

  Features are part of the [Cucumber Cloud Testsuite](https://github.com/suse-cloud/cct/).
  A feature is a collection of test cases being run at some point of installation workflow.



