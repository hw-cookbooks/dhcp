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

case node["platform"]
when "ubuntu"
  if node['platform_version'].to_f >= 12 then
    default[:dhcp][:directory] = "/etc/dhcp"
  end
else
  default[:dhcp][:directory] = "/etc/dhcp3"
end
