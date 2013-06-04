
action :add do
  filename = "#{node[:dhcp][:config_dir]}/subnets.d/#{new_resource.subnet}.conf"
  template filename do
    cookbook "dhcp"
    source "subnet.conf.erb"
    variables(
              :subnet => new_resource.subnet,
              :netmask => new_resource.netmask,
              :ranges => new_resource.ranges,
              :options => new_resource.options,
              :parameters => new_resource.parameters,
              :groups => new_resource.groups
              )
    owner "root"
    group "root"
    mode 0644
    file = Chef::Util::FileEdit.new("#{node[:dhcp][:config_dir]}/subnets.d/subnet_list.conf")
    file.insert_line_if_no_match("#{filename};","include \"#{filename}\";")
    file.write_file
    notifies :restart, resources(:service => node[:dhcp][:package]), :delayed
  end
end

action :remove do
  filename = "#{node[:dhcp][:config_dir]}/#{new_resource.name}.conf"
  if ::File.exists?(filename)
    Chef::Log.info "Removing #{new_resource.name} subnet from #{node[:dhcp][:config_dir]}/subnets.d/"
    file filename do
      action :delete
      notifies :restart, resources(:service => node[:dhcp][:package]), :delayed
    end
    new_resource.updated_by_last_action(true)
  end
  file = Chef::Util::FileEdit.new("#{node[:dhcp][:config_dir]}/subnets.d/subnet_list.conf")
  file.search_file_delete_line("include \"#{filename}\";")
  file.write_file
  notifies :restart, resources(:service => node[:dhcp][:package]), :delayed
end
