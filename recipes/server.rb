#
# Author:: Matt Ray <matt@opscode.com>
# Cookbook Name:: dhcp
# Recipe:: default
#
# Copyright 2011, Opscode, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

dhcp_pkg      = node['dhcp']['pkg']
dhcp_service  = node['dhcp']['service']
dhcp_conf_dir = node['dhcp']['conf_dir']

package dhcp_pkg

service dhcp_service do
  provider Chef::Provider::Service::Upstart if node['platform_version'].to_f >= 12.04
  supports :restart => true, :status => true, :reload => true
  action [ :enable ]
end

template "/etc/default/#{dhcp_service}" do
  owner "root"
  group "root"
  mode 0644
  source "dhcp3-server.erb"
  variables(:interfaces => node['dhcp']['interfaces'])
end

#get any default attributes and merge them with the data bag items
#convert them to the proper formatted lists, sort, and pass into template
default = data_bag_item('dhcp', 'default')

allows = node['dhcp']['allows'] || []
allows.push(default['allows']).flatten!
allows.uniq!
allows.sort!
Chef::Log.debug "allows: #{allows}"

parameters = []
parametersh = {}
node['dhcp']['parameters'].each {|k, v| parametersh[k] = v}
parametersh.merge!(default['parameters'])
parametersh.each {|k, v| parameters.push("#{k} #{v}")}
parameters.sort!
Chef::Log.debug "parameters: #{parameters}"

options = []
optionsh = {}
node['dhcp']['options'].each {|k,v| optionsh[k] = v}
optionsh.merge!(default['options'])
optionsh.each {|k, v| options.push("#{k} #{v}")}
options.sort!
Chef::Log.info "options: #{options}"

template "#{dhcp_conf_dir}/dhcpd.conf" do
  owner "root"
  group "root"
  mode 0644
  source "dhcpd.conf.erb"
  variables(
    :conf_dir => dhcp_conf_dir,
    :allows => allows,
    :parameters => parameters,
    :options => options
    )
  action :create
  notifies :restart, resources(:service => dhcp_service), :delayed
end

#groups
groups = []
directory "#{dhcp_conf_dir}/groups.d"

template "#{dhcp_conf_dir}/groups.d/group_list.conf" do
  owner "root"
  group "root"
  mode 0644
  source "list.conf.erb"
  variables(
    :item => "groups",
    :items => groups
    )
  action :create
  notifies :restart, resources(:service => dhcp_service), :delayed
end

#subnets
subnets = []
directory "#{dhcp_conf_dir}/subnets.d"

template "#{dhcp_conf_dir}/subnets.d/subnet_list.conf" do
  owner "root"
  group "root"
  mode 0644
  source "list.conf.erb"
  variables(
    :item => "subnets",
    :items => subnets
    )
  action :create
  notifies :restart, resources(:service => dhcp_service), :delayed
end

#hosts
hosts = []
directory "#{dhcp_conf_dir}/hosts.d"
template "#{dhcp_conf_dir}/hosts.d/host_list.conf" do
  owner "root"
  group "root"
  mode 0644
  source "list.conf.erb"
  variables(
    :item => "hosts",
    :items => hosts
    )
  action :create
  notifies :restart, resources(:service => dhcp_service), :delayed
end
