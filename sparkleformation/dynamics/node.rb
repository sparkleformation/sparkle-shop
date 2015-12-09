SparkleFormation.dynamic(:node) do |n_name, n_config|

  parameters do
    set!("#{n_name}_key_name").type 'String'
    set!("#{n_name}_instance_size") do
      type 'String'
      default 'm1.small'
    end
    set!("#{n_name}_ami_id") do
      type 'String'
      default 'ami-c0e78ba0'
    end
  end

  instance_resource = dynamic!(:ec2_instance, n_name) do
    properties do
      image_id ref!("#{n_name}_ami_id".to_sym)
      key_name ref!("#{n_name}_key_name".to_sym)
      instance_type ref!("#{n_name}_instance_size".to_sym)
      if(n_config[:vpc])
        network_interfaces array!(
          -> {
            device_index 0
            associate_public_ip_address 'true'
            subnet_id select!(0, ref!(:networking_subnet_ids))
          }
        )
      end
    end
  end

  outputs do
    set!("#{n_name}_instance_address") do
      value attr!("#{n_name}_ec2_instance".to_sym, :public_ip)
    end
  end

  instance_resource

end
