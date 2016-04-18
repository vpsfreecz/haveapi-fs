HaveAPI Filesystem
==================
`haveapi-fs` is a virtual read-write file system created using FUSE. It works
with any API based on [HaveAPI](https://github.com/vpsfreecz/haveapi) and
allows it to be browsed and interacted with as directories and files. The file
system can be easily extended to add custom directories/files or modify
behaviour for your API's needs.

## Requirements
FUSE has to be enabled in kernel and userspace utilities installed, e.g. on
Debian:

    $ apt-get install fuse libfuse-dev

## Installation

    $ gem install haveapi-fs

## Usage

    $ haveapi-fs -h
    Usage:
     haveapi-fs api_url mountpoint [-h] [-d] [-o [opt,optkey=value,...]]
    
    Fuse options: (2.9)
    -h                     help - print this help output
    -d |-o debug           enable internal FUSE debug output

    Filesystem options:
        version=VERSION        API version to use
        auth_method=METHOD     Authentication method (basic, token, noauth)
        user                   Username
        password               Password
        token                  Authentication token
        nodaemonize            Stay in the foreground
        log                    Enable logging while daemonized
        index_limit=LIMIT      Limit number of objects in resource directory

## `/etc/fstab` entry

There are two ways in which `haveapi-fs` can be added to `/etc/fstab`. Both
require that the `haveapi-fs` executable is in `$PATH`. The first approach is
to use `mount.fuse`:

    # <fs>                             <mountpoint>         <type>      <opts>  <dump/pass>
    haveapi-fs#https://api.domain.tld  /mnt/api.domain.tld   fuse        user      0   0

The other way is to link `/sbin/mount.haveapi-fs` to `haveapi-fs`, e.g.:

    $ ln -s `which haveapi-fs` /sbin/mount.haveapi-fs

Then we can use filesystem type `haveapi-fs` in fstab directly:

    # <fs>                             <mountpoint>         <type>      <opts>  <dump/pass>
    https://api.domain.tld             /mnt/api.domain.tld  haveapi-fs   user      0   0   

## Example
The following example uses [vpsadmin-api](https://github.com/vpsfreecz/vpsadmin-api),
which requires users to be authenticated.

`haveapi-fs` supports all available authentication methods, it defaults to
HTTP basic and it will prompt the user to input credentials, if they are not
supplied as options using `-o`.

    $ haveapi-fs https://api.vpsfree.cz /mnt/api.vpsfree.cz
    User name: <username>
    Password:

The root directory contains a list of top-level resources in the API
represented by directories. `help.{html,man,md,txt}` files are to be found in
every directory in this file system and contain information about the current
directory.

    $ cd /mnt/api.vpsfree.cz
    $ tree -L 1
    .
    ├── location/
    ├── environment/
    ├── node/
    ├── vps/
    ├── help.html
    ├── help.man
    ├── help.md
    ├── help.txt
    ├── .client_version
    ├── .fs_version
    ├── .protocol_version
    ├── .reset
    └── .unsaved

Inside a resource directory we can see the objects themselves as directories
whose name is their id.

    $ tree -L 1 vps
    vps
    ├── 198/
    ├── 199/
    ├── 202/
    ├── actions/
    ├── by-environment/
    ├── by-limit/
    ├── by-location/
    ├── by-node/
    ├── by-object_state/
    ├── by-offset/
    ├── by-os_template/
    ├── create.yml
    ├── help.html
    ├── help.man
    ├── help.md
    └── help.txt

Directory `actions/` contains resource-level actions like `Index` and `Create`.
Directories named as `by-<input_param>` represent input parameters of action
`Index` and serve as a quick way to filter by them, e.g.:

    $ tree -L 1 vps/by-environment/3/by-node/5
    vps/by-environment/3/by-node/5
    ├── 202/
    ├── actions/
    ├── by-environment/
    ├── by-limit/
    ├── by-location/
    ├── by-node/
    ├── by-object_state/
    ├── by-offset/
    ├── by-os_template/
    ├── create.yml
    ├── help.html
    ├── help.man
    ├── help.md
    └── help.txt

Only VPS #202 matches the filters.

Object directory contains a list of attributes, instance-level actions and
subresources. Associated resources can be browsed as directories.

    $ tree -L 1 vps/199/
    vps/199/
    ├── actions/
    ├── id
    ├── hostname
    ├── node/
    ├── node_id
    ├── os_template/
    ├── os_template_id
    ├── ...
    ├── edit.yml
    ├── help.html
    ├── help.man
    ├── help.md
    ├── help.txt
    └── save

Now let's look at the action directory:

    $ tree -L 1 vps/199/actions/update/
    vps/199/actions/update/
    ├── errors/
    ├── exec
    ├── exec.yml
    ├── help.html
    ├── help.man
    ├── help.md
    ├── help.txt
    ├── input/
    ├── message
    ├── output/
    ├── reset
    └── status

On the lowest level, actions are always invoked using file `exec`. All
executable files can be run in two ways, either write `1` into them or execute
them, e.g.:

    $ echo 1 > vps/199/actions/restart/exec

is the same as

    $ ./vps/199/actions/restart/exec

The success of this operation can be checked in files `status`, `message` and
directory `errors`. Use executable file `reset` to reset the state of these
files.

Input and output parameters are accessible as files in directories `input`
and `output`.

## Authentication
Authentication method is selected using option `auth_method`. Accepted values
are `basic`, `token` and `noauth`. If the option is not specified, config file
of [haveapi-client](https://github.com/vpsfreecz/haveapi-client) is checked,
otherwise it defaults to HTTP basic.

If needed parameters are not provided as options, the program prompts for them
on stdin.

## Executables
All executables can be called either by writing `1` to them or executing them.

## Run actions using YAML files
Resource directory has `create.yml` to create a new instance, instance
directory has `edit.yml` to update an instance and actions have `exec.yml`.

All these files contain a hash of input parameters and their values for
respective actions. The action is called when this file is saved, closed and
is not empty.

## Unsaved data
The filesystem tracks changed and unsaved files and takes care not to lose
them. Normal directories and files are freed from memory after some period of
inactivity, but unsaved files are held forever. A list of such files can be
found in a hidden file `.unsaved` located in every directory. The file always
contains paths to unsaved files in the current directory and all its
descendants.

To drop these unsaved files, use executable `.reset`, which is also located in
every directory.

## Access time, modification time and creation time
Access time is always updated, it is used to decide which directories/files may
be freed from memory. Components not accessed within the last 10 minutes are
regularly freed.

Modification time is changed only for files representing input parameters or
instance attributes.

Creation time is advertised as the time at which the component (directory/file)
was created in memory, i.e. for some components that is when they were fetched
from the API. As of now, components with creation time older than 30 minutes
are regularly freed from memory to ensure that the files and data you see are
still actually in the API, or have not been modified.

## Limiting number of fetched objects
By default, resource dir contains all its objects. For some APIs, it may be
undesirable, as they may contain too many objects and it is useless and slow to
fetch them all. For this reason, there is option `index_limit`, e.g.
`index_limit=2000` to fetch 2000 objects from every resource at most.

## Extending the file system
Internally, every directory and file is represented by a `Component` object.
Components are arranged in a tree structure, where directories are branches and
files are leaves. Any component can be modified or replaced.

The following example demonstrates how to add a custom file to an existing
component.

```ruby
#!/usr/bin/env ruby
require 'haveapi/fs'

module CustomComponents
  # Extends ResourceInstanceDir and adds file `extended.txt`
  class InstanceDir < HaveAPI::Fs::Components::ResourceInstanceDir
    # If not specified, class name is used as a help file name
    help_file :resource_instance_dir

    # This method returns directory contents. Return entries from the superclass
    # and add our own file.
    def contents
      super + %w(extended.txt)
    end

    protected
    # `new_child` is called whenever a path in the file system is accessed for
    # the first time. It returns the class and arguments that will represent
    # a component under `name`.
    #
    # First, we let the superclass to try to find the component. If it does not
    # exist, we check whether it's our custom file.
    def new_child(name)
      if child = super
        child

      elsif name == :'extended.txt'
        SomeFile

      else
        nil
      end
    end
  end
  
  # Component representing `extended.txt`
  class SomeFile < HaveAPI::Fs::Components::File
    # This method returns file contents. File size is deduced from the return
    # value and access times are managed by the file system by default, so this
    # method is all that is needed. Default permissions make this file
    # read-only.
    def read
      "you have been extended!\n"
    end
  end
end

# Replace ResourceInstanceDir with our InstanceDir in component factory.
# Whenever the file system would create ResourceInstanceDir instance, it will
# create InstanceDir instead.
HaveAPI::Fs::Factory.replace(
    HaveAPI::Fs::Components::ResourceInstanceDir,
    CustomComponents::InstanceDir
)

# Mount the file system
HaveAPI::Fs.main
```

## Troubleshooting
Whenever `haveapi-fs` crashes, throws IO errors or misbehaves, helpful
information can be found in the log file. Logging is disabled by default when
daemonized, as it can grow large. It can be enabled using option `log`. The log
file is located at `~/.haveapi-fs/<api domain>/haveapi-fs.log`.

If `haveapi-fs` is run in the foreground using option `nodaemonize`, it logs
to standard output.

Whenever reporting an error, send also contents of the log file or search it
for a relevant backtrace.
