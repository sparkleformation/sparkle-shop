SparkleFormation.component(:vpc) do

  parameters do

    networking_subnet_ids.type 'CommaDelimitedList'
    networking_vpc_id.type 'String'

  end

end
