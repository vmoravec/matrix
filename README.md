# Matrix

This is a tool for cloud environments' deployment and testing.

It navigates the user with in main categories:

* stories - they represent various deployment scenarios combined with feature tests
* runners - they represent commands being executed to drive the stories to happyend

Every story has typically several runners, the more complex scenario is the more
runners it might have.


## Quick start

  1.  Check [system dependencies](#dependencies)
  2.  `git clone git@github.com:vmoravec/matrix`
  3.  `alias rake="bundle exec rake"` # more on this further below
  4.  `cd matrix && rake install`
  5.  `rake h`
  6. [Run a story!](#how-to-run-a-story)


## Dependencies

    zypper in rubygem-bundler ruby-devel
    zypper in gcc make lvm2 libvirt

  List of required rubygems can be found in file `matrix.gemspec` and in `Gemfile`.
  To have all local dependencies installed, please run the task
  `rake install` for installing the deps or `rake update` to update the deps.


## Installation

  Make sure you have installed all [dependencies](#dependencies) .

  After you have cloned the repository, install the required rubygems:

     rake install

  All rubygems will be installed into the directory `vendor/bundle` within the repo.
  Other dependencies are put into the `vendor/` directory.


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
     rake -T keyword # will match all tasks by provided keyword

  More specific information:

     rake targets
     rake features
     rake stories

  Get config dumps:

     rake config
     rake config:main
     rake config:targets

  Run a story:

     rake story:default

  Most of the runners' output goes currently into the log file in `log/matrix.log`.

  Run unit tests for code inside `lib` directory:

     rake spec


## What is a story?

  A story is maintained scenario with yaml file configuration and deployment path
  with tests executed at some specific checkpoints.


## What is a runner?

  Runners are commands that drive the installation.
  They are available as `rake` tasks and can be run separately outside of a story.


## What is a feature?

  Features are part of the [Cucumber Cloud Testsuite](https://github.com/suse-cloud/cct/).
  A feature is a collection of test cases being run at some point of installation workflow.


## How to run a story?

  Before running a story you need to pick a target for your cloud deployment.
  You either choose the `libvirt` driven target called `virtual` or a particular
  hardware you have permission to install on.
  The list of available hardware targets is available by

     rake targets

  This returns the list of all stories.

     rake stories

  Not all targets are supported by every story. To get the targets supported for a single
  story, you need to review its targets:

     rake story:default:targets  # returns all targets for story named 'default'

  You can get additional information on a single story, however you need to specify
  the target you point at:

     rake story:default:runners target=TARGET
     rake story:default:config target=TARGET
     rake story:default:features target=TARGET

  This is how to run story named 'default' targeting local virtualized environment:

     rake story:default target=virtual



