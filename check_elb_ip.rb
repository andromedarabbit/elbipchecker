require 'aws-sdk-core'
require 'yaml'
require 'optparse'

params = {
  lb_file: "/tmp/lbs.yaml",
  region:  "us-east-1"
}
OptionParser.new do |opt|
  opt.on("-a access_key", "AWS Access Key"){|v| params[:access_key_id] = v}
  opt.on("-s secret_key", "AWS Secret Access Key"){|v| params[:secret_access_key] = v}
  opt.on("-f datafile", "File path for storing past data"){|v| params[:lb_file] = v}
  opt.on("-r regionname", "Region name"){|v| params[:region] = v}
  opt.parse!(ARGV)
end

aws_config = {}
aws_config.update access_key_id: params[:access_key_id], secret_access_key: params[:secret_access_key] if params[:access_key_id] && params[:secret_access_key]
aws_config.update region: params[:region]

elb = Aws::ElasticLoadBalancing::Client.new(aws_config)

if File.exist?(params[:lb_file])
  past_lbs = YAML.load_file(params[:lb_file])
else
  p "No data file found. This seems first run."
  past_lbs = {}
end

lbs = {}
elb.describe_load_balancers.load_balancer_descriptions.each do |d|
  lbs[d.load_balancer_name] = 
    {fqdn: d.dns_name,
     ips: Resolv::DNS.new.getresources(d.dns_name, Resolv::DNS::Resource::IN::A).collect{|i| i.address.to_s}.sort}
end

open(params[:lb_file], "w") do |f|
  YAML.dump(lbs, f)
end

if ! lbs.eql? past_lbs and past_lbs.length > 0
  lbs.each do |lb|
    lb[1][:ips].each_with_index do |ip, i|
      if ip != past_lbs[lb[0]][:ips][i]
        puts "#{Time.now} #{lb[0]} IP changed #{past_lbs[lb[0]][:ips][i]} -> #{ip}"
      end
    end
  end
end

