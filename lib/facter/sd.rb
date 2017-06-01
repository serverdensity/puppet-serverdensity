require 'facter'
require 'json'

# just in case we don't get any of them
provider = nil
providerid = nil

if Facter.value('facterversion') >= '3'
    if Facter.value('ec2_metadata')
        metadata = Facter.value('ec2_metadata')
        # It's an amazon cloud.
        provider = 'amazon'
        providerid = metadata['instance-id']
    else
        # Check for GCE
        gce = nil
        if Facter.value('gce')
            # Facter already extracts GCE metadata.
            gce = Facter.value('gce')
        end
    end
else
    if Facter.value('ec2_instance_id')
        # It's an amazon cloud.
        provider = 'amazon'
        providerid = Facter.value('ec2_instance_id')
    else
        begin
            body = open("http://metadata/computeMetadata/v1beta1/?recursive=true&alt=json").read
        rescue
            body = nil
        end
        if body
            gce = ::JSON.parse(body)
        end
    end
end
if gce
    provider = 'google'
    providerid = gce['instance']['id'].to_s
    projectid = gce['project']['projectId']
end
if provider
    Facter.add(:sd_provider) { setcode { provider } }
    if providerid
        Facter.add(:sd_provider_id) { setcode { providerid } }
    end
   if projectid
        Facter.add(:sd_project_id) { setcode { projectid } }
    end
else
    Facter.debug "Unknown provider"
end
