SparkleFormation.new(:infrastructure) do

  AWSTemplateFormatVersion '2010-09-09'

  description 'My SparkleFormation Stack'

  parameters do
    stack_creator.type 'String'
    key_name.type 'String'
    instance_size do
      type 'String'
      default 'm1.small'
    end
    ami_id do
      type 'String'
      default 'ami-c0e78ba0'
    end
  end

  dynamic!(:ec2_instance, :my) do
    properties do
      image_id ref!(:ami_id)
      key_name ref!(:key_name)
      instance_type ref!(:instance_size)
    end
  end

  outputs.my_instance_address.value attr!(:my_ec2_instance, :public_ip)

end
