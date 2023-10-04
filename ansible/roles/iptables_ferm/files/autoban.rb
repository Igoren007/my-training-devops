#!/usr/bin/env ruby
require 'logger'
require 'optparse'
require 'ostruct'
require 'net/http'
require 'json'
require 'time'

class IpsetBanhammer

  def initialize(opts)
    @url = opts.url
    @action = opts.action || 'add'
    @debug = opts.debug || false
    @ipset_name = opts.ipset_name || 'auto_ban'
    @log = init_logger(opts.logoutput || STDOUT)
    @dry_run = opts.dry_run || false
  end

  def main
    @log.debug "Start ban hammer"
    update_ipset(@action,http_banlist,@ipset_name)
  end

private

  def init_logger(logoutput)
    log = Logger.new(logoutput)
    log.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime.strftime("%Y-%m-%d %H:%M:%S")} #{msg}\n"
    end
    if @debug
      log.level = Logger::DEBUG
    else
      log.level = Logger::INFO
    end
    return log
  end

  def ipset(action,ipset_name,item)
    cmd = "ipset #{action} -exist #{ipset_name} #{item} 2>&1"
    if @dry_run
      cmd = "echo #{cmd}"
    end
    result = `#{cmd}`.strip
    unless $?.success?
      raise "Failed to fetch ipset list with error: #{result}"
    end
  end

  def flush_ipset(name)
    @log.debug "Flush ipset #{name}"
    cmd = "ipset flush #{name} 2>&1"
    if @dry_run
      cmd = "echo #{cmd}"
    end
    result = `#{cmd}`.strip
    unless $?.success?
      raise "Failed to flush ipset #{name} with error: #{result}"
    end
  end

  # TODO: make proper delete/add scheme
  def update_ipset(action,banlist,name)
    flush_ipset(name)
      banlist.each do |ip|
        @log.info "Ban from ip: #{ip}"
        ipset('add',name,ip)
      end
  end

  def current_ipset(name)
    curr_ips = `ipset list #{name} 2>&1`.split("\n")
    unless $?.success?
      raise "Failed to fetch ipset list with error: #{curr_ips}"
    end
    curr_ips.slice!(0..6)
    @log.debug "Current ipset list #{name} contains: #{curr_ips}"
    return curr_ips
  end

  def entry_expired?(curr_time, entry)
    entry_time = DateTime.parse(entry['expiration'])
    entry_time < curr_time
  end

  def get_banlist_from_json(http_data)
    list = []
    curr_time = DateTime.now
    json_data = JSON.parse(http_data)

    if !json_data.empty?
      json_data.each do |entry|
        if !entry_expired?(curr_time, entry)
          list << entry['ip']
          @log.debug "Entry to ban: #{entry['ip']} (valid until: \"#{entry['expiration']}\", #{entry['comment']})"
        else
          @log.debug "Entry expired: #{entry['ip']} (valid until: \"#{entry['expiration']}\", #{entry['comment']})"
        end
      end
    else
      @log.error 'Empty JSON data received'
    end

    list.reject { |i| i.empty? }.uniq
  end

  def http_banlist
    raise "URL undefined" if @url.nil?
    uri = URI(@url)
    res = Net::HTTP.get_response(uri)
    @log.debug "Ban list url: #{uri}"
    if res.is_a?(Net::HTTPSuccess)
      list = get_banlist_from_json(res.body)
    else
      raise "Request to #{uri} with code #{res.code} #{res.body}"
    end
    @log.debug "Ban list: #{list}"
    return list
  end
end

class IpsetBanhammerOptionParser

  def self.parse(args)
    options = OpenStruct.new

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} [options]"

      opts.separator ""
      opts.separator "Options:"

      opts.on("-u", "--url [URL]", "Url with ban list in json format") do |url|
        options.url = url
      end

      opts.on("-d", "--debug", "Debug information") do
        options.debug = true
      end

      opts.on("-n", "--dry_run", "Do nothing only print") do
        options.dry_run = true
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

    end  #OptionParser.new
    opt_parser.parse!(args)
    options
  end  # parse()

end  # class ZkinventoryOptionParser

if __FILE__ == $0
  options = IpsetBanhammerOptionParser.parse(ARGV)
  bh = IpsetBanhammer.new(options)
  bh.main
end
