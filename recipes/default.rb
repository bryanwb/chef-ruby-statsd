#
# Cookbook Name:: petef-statsd
# Recipe:: default
#
# Copyright 2012, Bryan W. Berry
#
# Apache 2.0
#

gem_package "petef-statsd"

user node['statsd']['user']

directory "/var/log/statsd" do
  owner node['statsd']['user']
  group node['statsd']['user']
  recursive true
end

template "/etc/init/statsd.conf" do
  mode "0644"
  source "statsd.conf.erb"
  variables(
            :destination => "#{node['statsd']['protocol']}://#{node['statsd']['dest_server']}:#{node['statsd']['dest_port']}"
            )
  notifies :restart, "service[statsd]"
end

logrotate_app "statsd" do
  cookbook "logrotate"
  path node["statsd"]["log_file"]
  frequency "daily"
  rotate 7
  create "644 node['statsd']['user'] node['statsd']['user'] "
end

service "statsd" do
  provider Chef::Provider::Service::Upstart
  action [ :enable, :start]
end
