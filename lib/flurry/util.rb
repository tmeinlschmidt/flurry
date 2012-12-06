module Flurry

  class Struct < OpenStruct

    def initialize(data)
      new_data = {}
      data.each{|k,v| new_data[k.gsub(/^@/,'')] = v}
      super(new_data)
    end

  end

end
