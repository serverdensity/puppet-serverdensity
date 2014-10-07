require 'facter'

# just in case we don't get any of them
provider = nil
providerid = nil

if Facter.value('ec2_instance_id')
    # It's an amazon cloud.
    provider = 'amazon'
    providerid = Facter.value('ec2_instance_id')
end

if provider
    Facter.add(:sd_provider) { setcode { provider } }
    if providerid
        Facter.add(:sd_provider_id) { setcode { providerid } }
    end
else
    Facter.debug "Unknown provider"
end
