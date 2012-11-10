if node['platform_version'].to_f <= 10.04
  default[:dhcp][:pkg]      = "dhcpd3-server"
  default[:dhcp][:service]  = "dhcpd3-server"
  default[:dhcp][:conf_dir] = "/etc/dhcp3"
else
  default[:dhcp][:pkg]      = "isc-dhcp-server"
  default[:dhcp][:service]  = "isc-dhcp-server"
  default[:dhcp][:conf_dir] = "/etc/dhcp"
end

default[:dhcp][:interfaces] = [ "eth0" ]

default[:dhcp][:allows] = []

default[:dhcp][:parameters] = {
  "default-lease-time" => "600",
  "max-lease-time" => "7200",
  "ddns-update-style" => "none",
  "log-facility" => "local7"
}

default[:dhcp][:options] = {
  "domain-name" => "\"example.org\"",
  "domain-name-servers" => ["ns1.example.org", "ns2.example.org"]
}

