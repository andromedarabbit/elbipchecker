# elbipchecker

Checks IP address change of all ELBs in a specific region.

## How to install

```
$ git clone https://github.com/doublemarket/elbipchecker.git
$ cd elbipchecker
$ bundle install --path=vendor/bundle
$ bundle exec ruby check_elb_ip.rb
```

## Options

- -a ACCESS_KEY : AWS Access Key
- -s SECRET_KEY : AWS Secret Access Key
  - If you don't specify ACCESS_KEY and SECRET_KEY, the script try to use configuration in ~/.aws directory
- -f DATA_FILE : File path for storing past IP address data
  - default : /tmp/lbs.yaml
- -r REGION : Region name
  - default : us-east-1

