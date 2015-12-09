SparkleFormation.new(:infrastructure).load(:base).overrides do

  dynamic!(:node, :my_first)
  dynamic!(:node, :my_second)

end
