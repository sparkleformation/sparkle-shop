SparkleFormation.new(:infrastructure).load(:base, :vpc).overrides do

  dynamic!(:node, :my_first, :vpc => true)
  dynamic!(:node, :my_second, :vpc => true)

end
