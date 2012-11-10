
action :add do
  filename = "#{dhcp_conf_dir}/groups.d/#{new_resource.name}.conf"
  template filename do 
    cookbook "dhcp"
    source "group.conf.erb"
    variables(
      :name => new_resource.name,
      :options => new_resource.options
    )
    owner "root"
    group "root"
    mode 0644
    notifies :restart, resources(:service => dhcp_service), :delayed
  end
  utils_line "include \"#{filename}\";" do
    action :add
    file "#{dhcp_conf_dir}/groups.d/group_list.conf"
    notifies :restart, resources(:service => dhcp_service), :delayed
  end
end

action :remove do
  filename = "#{dhcp_conf_dir}/groups.d/#{new_resource.name}.conf"
  if ::File.exists?(filename)
    Chef::Log.info "Removing #{new_resource.name} group from #{dhcp_conf_dir}/groups.d/"
    file filename do
      action :delete
      notifies :restart, resources(:service => dhcp_service), :delayed
    end
    new_resource.updated_by_last_action(true)
  end
  utils_line "include \"#{filename}\";" do
    action :remove
    file "#{dhcp_conf_dir}/groups.d/group_list.conf"
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
