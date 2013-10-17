# Capistrano Deploy Lock
#
# Add "require 'capistrano/deploy_lock'" in your Capistrano deploy.rb.
# Based on deploy_lock.rb from https://github.com/bokmann/dunce-cap

require 'time'
# Provide advanced expiry time parsing via Chronic, if available
begin; require 'chronic'; rescue LoadError; end
begin
  # Use Rails distance_of_time_in_words_to_now helper if available
  require 'action_view'
  require 'capistrano/date_helper'
rescue LoadError
end

module Capistrano
  DeployLockedError = Class.new(StandardError)

  module DeployLock
    def self.message(application, stage, deploy_lock)
      if stage
        message = "#{application} (#{stage}) was locked"
      else
        message = "#{application} was locked"
      end
      if defined?(Capistrano::DateHelper)
        locked_ago = Capistrano::DateHelper.distance_of_time_in_words_to_now deploy_lock[:created_at].localtime
        message << " #{locked_ago} ago"
      else
        message << " at #{deploy_lock[:created_at].localtime}"
      end
      message << " by '#{deploy_lock[:username]}'\nMessage: #{deploy_lock[:message]}"

      if deploy_lock[:expire_at]
        if defined?(Capistrano::DateHelper)
          expires_in = Capistrano::DateHelper.distance_of_time_in_words_to_now deploy_lock[:expire_at].localtime
          message << "\nLock expires in #{expires_in}"
        else
          message << "\nLock expires at #{deploy_lock[:expire_at].localtime.strftime("%H:%M:%S")}"
        end
      else
        message << "\nLock must be manually removed with: cap #{stage} deploy:unlock"
      end
    end

    def self.expired_message(application, stage, deploy_lock)
      message = "#{application} (#{stage}) was locked"
      if defined?(Capistrano::DateHelper)
        locked_ago = Capistrano::DateHelper.distance_of_time_in_words_to_now deploy_lock[:created_at].localtime
        message << " #{locked_ago} ago"
      else
        message << " at #{deploy_lock[:created_at].localtime}"
      end
      message << " by '#{deploy_lock[:username]}'\nMessage: #{deploy_lock[:message]}"

      if deploy_lock[:expire_at]
        if defined?(Capistrano::DateHelper)
          expires_in = Capistrano::DateHelper.distance_of_time_in_words_to_now deploy_lock[:expire_at].localtime
          message << "\nLock expired #{expires_in} ago, unlocking..."
        else
          message << "\nLock expired at #{deploy_lock[:expire_at].localtime.strftime("%H:%M:%S")}"
        end
      else
        message << "\nLock must be manually removed with: cap #{stage ? stage + ' ' : ''}deploy:unlock"
      end
    end
  end
end

# Load recipe if required from deploy script
if defined?(Capistrano::Configuration) && Capistrano::Configuration.instance
  require 'capistrano/recipes/deploy_lock'
end
