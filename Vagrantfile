branch = %x{ git rev-parse --abbrev-ref HEAD}
Vagrant.configure("2") do |config|
  config.vm.define :cbt do |cbt_config|
    cbt_config.vm.synced_folder '.', '.', disabled: true
    cbt_config.vm.provider :aws do |aws, override|
      aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
      aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
      override.vm.box = "dummy"
      override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
      override.ssh.username = 'ec2-user'
      override.ssh.private_key_path = ENV['KEYPATH']
      aws.keypair_name = ENV['KEYPAIR_NAME']
      aws.ami = ENV['AMI_ID']
      aws.instance_type = "m3.xlarge"
      aws.ebs_optimized = true
      aws.block_device_mapping = [ 
      {
        'DeviceName' => '/dev/sdb',
        'VirtualName' => 'ephemeral0',
      },
      {
        'DeviceName' => '/dev/sdc',
        'VirtualName' => 'ephemeral1',
      }
    ]
    end
    cbt_config.ssh.pty = true
    #cbt_config.vm.provision "file", source: "setup.sh", destination: "setup.sh"
    #cbt_config.vm.provision "shell", path: "setup.sh", args: [branch]
  end
end
