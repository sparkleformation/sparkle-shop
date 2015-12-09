SparkleFormation.new(:computes).load(:base, :vpc).overrides do
  dynamic!(:node, :my_first, :vpc => true)
end
