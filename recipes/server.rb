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

package "dhcp3-server"

service "dhcp3-server" do
  case node["platform"]
  when "ubuntu"
    if node['platform_version'].to_f >= 12 then
      service_name "isc-dhcp-server"
    end
  end
  supports :restart => true, :status => true, :reload => true
  action [ :enable ]
end

template "/etc/default/dhcp3-server" do
  owner "root"
  group "root"
  mode 0644
  source "dhcp3-server.erb"
  variables(:interfaces => node['dhcp']['interfaces'])
end

#get any default attributes and merge them with the data bag items
#convert them to the proper formatted lists, sort, and pass into template
default = Array.new
begin
  default = data_bag_item('dhcp', 'default')
rescue Net::HTTPServerException
end

allows = node['dhcp']['allows'] || []
unless default.empty?
  allows.push(default['allows']).flatten!
end
allows.uniq
allows.sort
Chef::Log.debug "allows: #{allows}"

parameters = []
parametersh = {}
node['dhcp']['parameters'].each {|k, v| parametersh[k] = v}
unless default.empty?
  parametersh.merge(default['parameters'])
end
parametersh.each {|k, v| parameters.push("#{k} #{v}")}
parameters.sort
Chef::Log.debug "parameters: #{parameters}"

options = []
optionsh = {}
node['dhcp']['options'].each {|k,v| optionsh[k] = v}
unless default.empty?
  optionsh.merge(default['options'])
end
optionsh.each {|k, v| options.push("#{k} #{v}")}
options.sort
Chef::Log.info "options: #{options}"

dhcp_dir = node["dhcp"]["directory"]

template "#{dhcp_dir}/dhcpd.conf" do
  owner "root"
  group "root"
  mode 0644
  source "dhcpd.conf.erb"
  variables(
            :allows => allows,
            :parameters => parameters,
            :options => options,
            :dhcp_dir => dhcp_dir
            )
  action :create
  notifies :restart, resources(:service => "dhcp3-server"), :delayed
end

#groups
groups = []
directory "#{dhcp_dir}/groups.d"

template "#{dhcp_dir}/groups.d/group_list.conf" do
  owner "root"
  group "root"
  mode 0644
  source "list.conf.erb"
  variables(
            :item => "groups",
            :items => groups
            )
  action :create
  notifies :restart, resources(:service => "dhcp3-server"), :delayed
end

#subnets
subnets = []
directory "#{dhcp_dir}/subnets.d"

template "#{dhcp_dir}/subnets.d/subnet_list.conf" do
  owner "root"
  group "root"
  mode 0644
  source "list.conf.erb"
  variables(
            :item => "subnets",
            :items => subnets
            )
  action :create
  notifies :restart, resources(:service => "dhcp3-server"), :delayed
end

#hosts
hosts = []
directory "#{dhcp_dir}/hosts.d"
template "#{dhcp_dir}/hosts.d/host_list.conf" do
  owner "root"
  group "root"
  mode 0644
  source "list.conf.erb"
  variables(
            :item => "hosts",
            :items => hosts
            )
  action :create
  notifies :restart, resources(:service => "dhcp3-server"), :delayed
end
