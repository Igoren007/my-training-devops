#!/usr/bin/env ruby

require 'logger'

module Ipset

  $log = Logger.new('/var/log/ipset_updater.log', 10, 1024000)
  $log.formatter = proc do |severity, datetime, progname, msg|
     "#{datetime.strftime("%Y-%m-%d %H:%M:%S")} [#{severity}] #{msg}\n"
  end

  class IpsetRuler
    def initialize(loglevel='INFO')
      if loglevel == "DEBUG"
        $log.level = Logger::DEBUG
      else
        $log.level = Logger::INFO
      end
      $log.debug 'Start ipset ruler'
    end

    def add_ipset_ips(list,iplist)
      iplist.each do |ip|
        res = `/sbin/ipset add -exist #{list} #{ip} 2>&1`
        $log.info "Added ip #{ip}"
      end
    end

    def remove_ipset_ips(list,iplist)
      iplist.each do |ip|
        res = `/sbin/ipset del -exist #{list} #{ip} 2>&1`
        $log.info "Removed ip #{ip}"
      end
    end

    def update_ipset_list(list,new_ips)
      curr_ips = `/sbin/ipset list #{list} 2>&1`.split("\n")
      unless $?.success?
        raise "Failed to fetch ipset list with error: #{curr_ips}"
      end
      # remove first 7 lines of ipset output
      curr_ips.slice!(0..6)
      $log.debug "Current ipset list #{list} contains: #{curr_ips}"
      $log.debug "Updating #{list}"
      remove_ip_list = curr_ips - new_ips
      add_ip_list = new_ips - curr_ips
      add_ipset_ips(list,add_ip_list)
      remove_ipset_ips(list,remove_ip_list)
    end

  end # class IpsetRuler

end # module Ipset

