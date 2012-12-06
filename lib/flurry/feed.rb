module Flurry

  class Feed < Flurry::Struct
  
    attr_reader :recommendations

    def initialize(data)
      @recommendations = data.delete("recommendation").map{|r| Flurry::Recommendation.new(r)}
      super(data)
    end
  
  end

end
