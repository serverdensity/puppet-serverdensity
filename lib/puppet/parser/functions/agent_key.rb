require 'net/http'
require 'net/https'
require 'uri'

module Puppet::Parser::Functions

    newfunction(:agent_key, :type => :rvalue) do |args|

        sd_username = args[0]
        sd_password = args[1]
        sd_url = args[2]
        token = args[3]
        agent_key = args[4]
        server_name = args[5]
        group = args[6]
        use_fqdn = args[7]

        hostname = lookupvar("hostname")
        fqdn = lookupvar("fqdn")

        if server_name.nil? or server_name.empty?
            server_name = fqdn
        end

        if use_fqdn
            notice "Using fqdn for hostname"
            hostname = fqdn
            checks = [hostname]
        else
            # if we don't explicitly want to use the fqdn
            # then we should check hostname and fqdn
            checks = [hostname, fqdn]
        end


        notice ["Server Name: #{ server_name }"]

        sd_url = sd_url.sub(/^https?\:\/\//, '')

        # can we get the agent key from the environment
        # we set it on cloud devices created on Amazon or Rackspace
        # created via the serverdensity UI
        # uses custom agent_key fact
        agent_key = lookupvar("agent_key")

        # lookupvar returns undef if no value
        # test against nil just in case
        unless agent_key.nil? or agent_key == :undef
            notice ["Agent Key Provided via Facter: #{ agent_key }"]
            return agent_key
        end

        if agent_key == :undef
            agent_key = ""
        end

        unless agent_key.nil? or agent_key.empty?
            notice ["Agent Key Provided: #{ agent_key }"]
            return agent_key
        end

        if sd_url.nil? or sd_url.empty?
            raise Puppet::ParseError, "SD URL not set"
        end

        if token.nil? or token.empty?
            api_version = "1.4"
        else
            api_version = "2"
        end


        if api_version == "1.4"

            if sd_password.nil? or sd_password.empty?
                raise Puppet::ParseError, "SD Password not set"
            end
            if sd_username.nil? or sd_username.empty?
                raise Puppet::ParseError, "SD Username not set"
            end

            notice ["Starting retrieval"]
            base_url = 'http://api.serverdensity.com/1.4/'
            # attempt to find the device by hostname (which may be local or FQDN)
            device = nil
            checks.each do |hn|
                uri = URI("#{ base_url }devices/getByHostName?hostName=#{ hn }&account=#{ sd_url }")

                req = Net::HTTP::Get.new(uri.request_uri)
                req.basic_auth sd_username, sd_password

                res = Net::HTTP.start(uri.host, uri.port) {|http|
                    http.request(req)
                }
                device = PSON.parse(res.body)
                if device['status'] == 1
                    # keep this response -- device was found
                    break
                end
            end

            if device['status'] == 2
                notice ["Device not found, creating a new one"]

                uri = URI("#{ base_url }devices/add?account=#{ sd_url }")
                req = Net::HTTP::Post.new(uri.request_uri)
                req.basic_auth sd_username, sd_password

                params = {
                    'name' => server_name,
                    'hostName' => hostname,
                    'notes' => 'Created automatically by puppet-serverdensity',
                }

                unless group.nil? or group.empty?
                    params['group'] = group
                end

                # Create new device
                req.set_form_data(params)

                res = Net::HTTP.start(uri.host, uri.port) {|http|
                    http.request(req)
                }
                device = PSON.parse(res.body)

                if device['status'] == 2
                    message = device['error']['message']
                    raise Puppet::ParseError, "Failure creating new device: #{ message }"
                end

                agent_key = device['data']['agentKey']
            else
                notice ["Reusing existing device"]
                # Validate that the found device is correct (this is to correct
                # for erroneous results that can be returned from the API
                # getByHostName query)
                found_hostname = device['data']['device']['hostName']
                if not checks.include? found_hostname
                    raise Puppet::ParseError, "Serverdensity getByHostname API call returned a device with mismatching hostname '#{found_hostname}'.  You may need to recreate device(s)."
                end
                agent_key = device['data']['device']['agentKey']
            end

        elsif api_version == "2"
            notice ["Using SD Version 2"]

            base_url = "https://api.serverdensity.io"

            # attempt to find the device by hostname (which may be local or FQDN)
            list = nil
            checks.each do |hn|
                filter = {
                    'type' => 'device',
                    'hostname' => hn,
                }

                filter_json = URI.escape(PSON.dump(filter))

                notice ["Making API request"]

                begin
                    uri = URI("#{ base_url }/inventory/devices?filter=#{ filter_json }&token=#{ token }")
                    req = Net::HTTP::Get.new(uri.request_uri)
                    https = Net::HTTP.new(uri.host, uri.port)
                    https.use_ssl = true
                    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
                    res = https.start { |cx| cx.request(req) }

                    list = PSON.parse(res.body)

                rescue
                    err ["Error from SD API, stopping run"]
                    raise Puppet::ParseError, "Error from SD API"
                end

                if Integer(res.code) >= 500
                    err ["Error from SD API, stopping run"]
                    raise Puppet::ParseError, "Error from SD API"
                end

                if list.length > 0
                    # keep this response -- device was found
                    break
                end
            end

            if Integer(res.code) >= 300 or list.length == 0
                notice ["Device not found, creating a new one"]

                data = {
                    :name => server_name,
                    :hostname => hostname,
                }
                unless group.nil? or group.empty?
                    data['group'] = group
                end

                uri = URI("#{ base_url }/inventory/devices?token=#{ token }")
                req = Net::HTTP::Post.new(uri.request_uri)

                # Create new device
                req.set_form_data(data)

                https = Net::HTTP.new(uri.host, uri.port)
                https.use_ssl = true
                https.verify_mode = OpenSSL::SSL::VERIFY_NONE
                res = https.start { |cx| cx.request(req) }

                device = PSON.parse(res.body)

            else
                device = list[0]

                # Has the group changed?
                existing_group = device["group"]

                if existing_group != group
                    notice ["Updating group on #{device['_id']} from #{existing_group} to #{group}"]

                    # update the group
                    uri = URI("#{ base_url }/inventory/devices/#{ device['_id'] }?token=#{ token }")

                    req = Net::HTTP::Put.new(uri.request_uri)

                    update_data = {
                        :group => group
                    }
                    req.set_form_data(update_data)
                    https = Net::HTTP.new(uri.host, uri.port)
                    https.use_ssl = true
                    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
                    res = https.start { |cx| cx.request(req) }

                end
            end

            agent_key = device["agentKey"]
        end

        notice ["Agent Key: #{ agent_key }"]
        return agent_key
    end
end
