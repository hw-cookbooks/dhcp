
action :add do
  filename = "#{dhcp_conf_dir}/subnets.d/#{new_resource.subnet}.conf"
  template filename do 
    cookbook "dhcp"
    source "subnet.conf.erb"
    variables(
      :subnet => new_resource.subnet,
      :netmask => new_resource.netmask,
      :broadcast => new_resource.broadcast,
      :routers => new_resource.routers,
      :options => new_resource.options
    )
    owner "root"
    group "root"
    mode 0644
    notifies :restart, resources(:service => dhcp_service), :delayed
  end
  utils_line "include \"#{filename}\";" do
    action :add
    file "#{dhcp_conf_dir}/subnets.d/subnet_list.conf"
    notifies :restart, resources(:service => dhcp_service), :delayed
  end
end

action :remove do
  filename = "#{dhcp_conf_dir}/subnets.d/#{new_resource.name}.conf"
  if ::File.exists?(filename)
    Chef::Log.info "Removing #{new_resource.name} subnet from #{dhcp_conf_dir}/subnets.d/"
    file filename do
      action :delete
      notifies :restart, resources(:service => dhcp_service), :delayed
    end
    new_resource.updated_by_last_action(true)
  end
  utils_line "include \"#{filename}\";" do
    action :remove
    file "#{dhcp_conf_dir}/subnets.d/subnet_list.conf"
    notifies :restart, resources(:service => dhcp_service), :delayed
  end
end

private

def dhcp_service
  node['dhcp']['service']
end

def dhcp_conf_dir
  node['dhcp']['conf_dir']
end
