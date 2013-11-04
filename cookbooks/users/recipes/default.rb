#
# Cookbook Name:: users
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

gem_package 'ruby-shadow'

search(:users, "*:*").each do |user_data|
  user user_data['id'] do
    supports :manage_home => true
    comment user_data['comment']
    uid user_data['uid']
    gid user_data['gid']
    home user_data['home']
    shell user_data['shell']
    password user_data['password']
  end
  if user_data['sudo']
    template "/etc/sudoers.d/#{user_data['id']}" do
      source "sudoers.conf.erb"
      mode 0440
      variables(
        :user => user_data['id']
      )
    end
  end
end

include_recipe "users::groups"
