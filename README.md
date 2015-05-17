# `matrix`

__`Story runner for cloud testsuite`__

## Todos

* timeout and counter + progress bar
  Every runner or feature has a timeout of 5-10 minutes by default. 
  The counter will expect parameters in seconds to update the progress bar
  Real elapsed time and timeout will be attributes of every feature or runner object
  together with time start and time end plus result of the command.
  Use something like this: http://stackoverflow.com/questions/15892738/perform-a-loop-for-a-certain-time-interval-or-while-condition-is-met
  On the start of every command, the progress bar will show:
    - stage/checkpoint to be reached
    - timeout to finish
    - when the command exits (with success or failure), the progress bar will change and reflect that change
    - all these events will be captured into the structured output

* output analyser for remote and local command
  If the analyser mixed into a class, it will provide an interface
  to register regexps with types (start, end, checkpoint, result ...) and descriptions for the successful match.
  Will scan every single line of the command to interpret it
  Maybe a separate configuration file would be practical (idea)

* runners' and features' progress data capture engine to measure:
  time elapsed
  time started
  stage achieved
  stage result
  timeout for stage
  tiemout for runners and features
  ...



## Quick start

  1.  Check [system dependencies](#dependencies)
  2.  `git clone git@github.com:vmoravec/matrix`
  3.  `cd matrix && bundle install`
  4.  `alias rake="bundle exec rake"` # more on this further below
  5.  `rake git:automation:clone`
  6.  `rake h`
  7.  `rake story:default`

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


## Issues

  Currently this program expects you have the kernel module `loop` loaded, it does
  not that for you automatically. Make sure the `loop` is available by `sudo modprobe loop`.

  Internaly there is the `mkcloud` command used for driving the cloud installation. It 
  will prompt you to provide your password (or root password, depends on your `/etc/sudoers` file).
  As a single story calls `mkcloud` several times, the story workflow will fail
  without you paying attention. I recommend either
    * `sudo su && bundle exec rake story:default`
    * or updating your `/etc/sudoers` file with `$USER ALL=(ALL) NOPASSWD:ALL`


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



