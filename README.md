# Capistrano Deploy Lock

Lock a server during deploy, to prevent people from deploying at the same time.


## Installation

Add this line to your application's Gemfile:

    gem 'capistrano_deploy_lock'

And then execute:

    $ bundle

Add this line to your `config/deploy.rb`:

    require 'capistrano/deploy_lock'

## Usage

Your deploys will now be protected by a lock. Simply run `cap deploy` as usual.
However, if someone else trys to deploy at the same time, their deploy will abort
with an error like this:

```
*** Deploy locked 3 minutes ago by 'ndbroadbent'
*** Message: Deploying master branch
*** Expires in 12 minutes
.../capistrano/deploy_lock.rb:132:in `block (3 levels) in <top (required)>': Capistrano::DeployLockedError (Capistrano::DeployLockedError)
```

The default deploy lock will expire after 15 minutes. This is so that crashed or interrupted deploys don't leave a stale lock
for the next developer to deal with. If your deploys usually take longer than this, the expiry time can be configured with:

    set :default_lock_expiry, (20 * 60)   # Sets the default expiry to 20 minutes

Anyone can remove a lock by running:

    cap deploy:unlock

The lock file will be created at `#{shared_path}/capistrano.lock.yml` by default. You can configure this with:

    set :deploy_lockfile, "path/to/deploy/lock/file"


## Manual locks

You can explicitly set a deploy lock by running:

    cap deploy:lock

You will receive two prompts:

* Lock Message:

Type the reason for the lock. This message will be displayed to any developers who attempt to deploy.

* Expire lock at? (optional):

Set an expiry time for the lock. Leave this blank to make the lock last until someone removes it with `cap deploy:unlock`.

If the [chronic](https://github.com/mojombo/chronic) gem is available, you can type
natural language times like `2 hours`, or `tomorrow at 6am`. If not, you must type times in a format that `DateTime.parse()` can handle,
such as `06:30:00` or `2012-12-12 00:00:00`.

The `cap deploy:check_lock` task will automatically delete any expired locks.

## Thanks

Special thanks to [David Bock](https://github.com/bokmann), who wrote the [deploy_lock.rb](https://github.com/bokmann/dunce-cap/blob/master/recipes/deploy_lock.rb)
script that this is based on.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
