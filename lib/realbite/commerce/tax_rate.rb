module Commerce
  ########################################################################
  # TaxRate class - the hard reality
  # 
  ########################################################################
  class TaxRate
    attr_accessor :code
    attr_accessor :name
    
    # create a new TaxRate, the code must be letters or numbers.
    def initialize( code,  r=0, name=nil)
      raise ArgumentError, "Tax code #{code} can only contain letters, numbers or _ (underbar)" unless code=~/^[a-z_0-9*]+$/i
      @name = name || code
      @code = code 
      @rate = r.to_f
    end
    
    def self.new_with_code_and_rate( code, r=0)
      new(code,r)
    end  
    
    # calculate tax amount from inclusive amount
    def incl_rate
      1.0 - (1.0/(1.0+@rate) )
    end
    
    # rate applied to ex tax amount
    def rate=(r)
      @rate = r.to_f
    end
    
    def rate
      @rate
    end
    
    def to_s
      "#{@code}(#{ (@rate*100000).round / 1000.0 }%)"
    end
    
    def to_f
      @rate
    end
    
    def ==(other)
      return unless other.kind_of? TaxRate
       (code==other.code) && (rate==other.rate)
    end
    
    def <=>(other)
      rate <=> other.rate
    end
    
  end
  
end #Commerce