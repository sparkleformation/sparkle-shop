SparkleFormation.new(:vpc) do

  set!('AWSTemplateFormatVersion', '2010-09-09')

  description 'Networking stack'

  parameters do
    vpc_cidr_block_16 do
      type 'CommaDelimitedList'
      default '172,63,0,0'
      disable_apply true
    end
  end

  dynamic!(:ec2_vpc, :networking,
    :cidr_block => join!(
      join!(
        ref!(:vpc_cidr_block_16),
        :options => {
          :delimiter => '.'
        }
      ),
      '/16'
    ),
    :enable_dns_support => 'true',
    :enable_dns_hostnames => 'true'
  )

  dynamic!(:ec2_dhcp_options, :networking,
    :domain_name => join!(region!, '.compute.internal'),
    :domain_name_servers => ['AmazonProvidedDNS']
  )

  dynamic!(:ec2_vpc_dhcp_options_association, :networking,
    :dhcp_options_id => ref!(:networking_ec2_dhcp_options),
    :vpc_id => ref!(:networking_ec2_vpc)
  )

  dynamic!(:ec2_internet_gateway, :networking)

  dynamic!(:ec2_vpc_gateway_attachment, :networking,
    :internet_gateway_id => ref!(:networking_ec2_internet_gateway),
    :vpc_id => ref!(:networking_ec2_vpc)
  )

  dynamic!(:ec2_route_table, :networking,
    :vpc_id => ref!(:networking_ec2_vpc)
  )

  dynamic!(:ec2_route, :networking_public,
    :destination_cidr_block => '0.0.0.0/0',
    :gateway_id => ref!(:networking_ec2_internet_gateway),
    :route_table_id => ref!(:networking_ec2_route_table)
  )

  2.times do |i|
    dynamic!(:ec2_subnet, "networking_#{i}".to_sym) do
      properties do
        availability_zone select!(i, azs!)
        cidr_block join!(
          join!(
            select!(0, ref!(:vpc_cidr_block_16)),
            select!(1, ref!(:vpc_cidr_block_16)),
            :options => {
              :delimiter => '.'
            }
          ),
          ".#{i}.0/24"
        )
        vpc_id ref!(:networking_ec2_vpc)
      end
    end

    dynamic!(:ec2_subnet_route_table_association, "networking_#{i}".to_sym,
      :route_table_id => ref!(:networking_ec2_route_table),
      :subnet_id => ref!("networking_#{i}_ec2_subnet".to_sym)
    )
  end

  dynamic!(:ec2_security_group_ingress, :networking_ssh,
    :cidr_ip => '0.0.0.0/0',
    :from_port => 22,
    :to_port => 22,
    :ip_protocol => 'tcp',
    :group_id => attr!(:networking_ec2_vpc, :default_security_group)
  )

  outputs do
    networking_vpc_id do
      description 'VPC ID for network'
      value ref!(:networking_ec2_vpc)
    end
    networking_subnet_ids do
      description 'VPC Subnet ID for network'
      value join!(
        *2.times.map{|i| ref!("networking_#{i}_ec2_subnet".to_sym)},
        :options => {
          :delimiter => ','
        }
      )
    end
    networking_route_table do
      description 'Default networking route table'
      value ref!(:networking_ec2_route_table)
    end
  end

end
