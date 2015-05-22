require 'aws-sdk-core'
require 'yaml'

LB_FILE = Dir::pwd+"/lbs.yaml"
REGION = "ap-northeast-1"

elb = Aws::ElasticLoadBalancing::Client.new(region: REGION)

if File.exist?(LB_FILE)
  past_lbs = YAML.load_file(LB_FILE)
else
  p "No yaml file found"
  past_lbs = {}
end

lbs = {}
elb.describe_load_balancers.load_balancer_descriptions.each do |d|
  lbs[d.load_balancer_name] = 
    {fqdn: d.dns_name,
     ips: Resolv::DNS.new.getresources(d.dns_name, Resolv::DNS::Resource::IN::A).collect{|i| i.address.to_s}.sort}
end

if ! lbs.eql? past_lbs and past_lbs.length > 0
  lbs.each do |lb|
    lb[1][:ips].each_with_index do |ip, i|
      if ip != past_lbs[lb[0]][:ips][i]
        p "LB #{lb[0]} IP #{past_lbs[lb[0]][:ips][i]} -> #{ip}"
      end
    end
  end
end

open(LB_FILE, "w") do |f|
  YAML.dump(lbs, f)
end

