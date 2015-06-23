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
     rake -T
     rake -T keyword

  More specific help:

     rake config
     rake config:main
     rake config:targets
     rake features
     rake stories

  Story specific help:

     rake story:default:targets
     rake story:default:runners
     rake story:default:config
     rake story:default:features

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
  They are available as `rake` tasks and can be run separately outside of a story run.

## What is a feature?

  Features are part of the [Cucumber Cloud Testsuite](https://github.com/suse-cloud/cct/).
  A feature is a collection of test cases being run at some point of installation workflow.



