SparkleFormation.component(:base) do

  AWSTemplateFormatVersion '2010-09-09'

  description 'My SparkleFormation Stack'

  parameters do
    stack_creator.type 'String'
  end

  outputs.stack_creator.value ref!(:stack_creator)

end
