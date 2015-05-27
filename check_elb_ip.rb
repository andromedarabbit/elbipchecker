require 'aws-sdk-core'
require 'yaml'
require 'optparse'

params = {}
OptionParser.new do |opt|
  opt.on("-f datafile", "File name for storing past data"){|v| params[:lb_file] = Dir::pwd+"/#{v}"}
  opt.on("-r regionname", "Region name"){|v| params[:region] = v}
  opt.parse!(ARGV)
end

elb = Aws::ElasticLoadBalancing::Client.new(region: params[:region])

if File.exist?(params[:lb_file])
  past_lbs = YAML.load_file(params[:lb_file])
else
  p "No data file found"
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
  open(params[:lb_file], "w") do |f|
    YAML.dump(lbs, f)
  end

  exit 1
end

