module Commerce
  
  ########################################################################
  # ExchangeRate class - convert between currencies
  # 
  ########################################################################
  class ExchangeRate
    
    attr_accessor :from, :to, :rate
    
    @list = {}
    def initialize(from,to,rate)
      @from = from
      @to = to
      @rate = rate
    end
    
    def to_s
      "#{from.symbol} to #{to.symbol} - #{rate}"
    end
    
    def inspect
      "ExchangeRate " + to_s
    end
  end
end