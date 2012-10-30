module Commerce
  
  ########################################################################
  # Money class - the hard stuff. An immutable class ( you cannot change
  #   the currency or amount )
  # 
  ########################################################################
  class Money
    
    include Comparable
    
    # initialize with an amount (Number) and a 
    # Currency code
    def initialize(amt,curr_code)
      raise ArgumentError, "missing currency code" unless curr_code
      curr_code = curr_code.to_s.upcase
      raise ArgumentError, "missing currency code" if curr_code.empty?
      raise ArgumentError, "invalid currency code: #{curr_code}" unless curr_code =~ /^[A-Z]{3,3}$/
      @amount   =  BigDecimal.new(amt.to_s)
      @code     = curr_code
      @currency = nil
    end
    
    # the currency code
    def code
      @code
    end
    
    # currency object
    def currency
      @currency ||= Currency.find(code)
    end
    
    # get the amount (BigDecimal) and round to the number of places if
    # supplied.
    def amount(places=nil)
      if places
        
      else
        @amount
      end
    end
    
    def to_places(places)
      self.class.new( amount.to_places(places),code)
    end
    
    
    # add two money values
    def +(other)
      check_valid(other)
      self.class.new( (amount + other.amount) , code )
    end
    
    # minus a money value
    def -@
      self.class.new( (-amount) , code )
    end
    
    # subtact two money values
    def -(other)
      check_valid(other)
      self.class.new( (amount - other.amount) , code )
    end
    
    # multiply a money value by a number
    def *(op)
      mult = BigDecimal.new(op.to_s)
      self.class.new(  amount * mult ,code ) 
    end
    
    # divide a money value by a number
    def /(op)
      if op.to_f==0.0
        raise "attemp to divide by zero !! "
      end
      div = BigDecimal.new(op.to_s)
      self.class.new( ( amount / div ) , code )
    end
    
    # convert to a float ( fraction of whole units eg:euros )
    def to_f
      amount.to_f
    end
    
    def round
      to_cents.to_f / currency.multiplier
    end
    
    # convert to cents ( number of smallest units eg: eurocents )
    # there is a bug in BigDecimal which does not round numbers from 0.5 < x > 0.6
    # correctly so we have to do the bankers rounding long hand !!
    def to_cents
      negative = amount < 0 ? -1 : 1
      cents = (amount * currency.multiplier) * negative
      whole_cents = cents.round(0,BigDecimal::ROUND_DOWN).to_i
      difference  = cents.frac
      whole_cents +=1 if difference > 0.5
      whole_cents +=1 if (difference == 0.5) && (whole_cents.modulo(2)==1)
      whole_cents * negative
    end
    
    
    # convert to string by rounding to smallest unit and diplaying with 
    # the currency symbol and the
    # correct number of decimal places. pass a seperator if it is other than '.'.
    def to_s(sep='.')
      "#{currency.symbol} #{to_s_short(sep) }"
    end
    
    # same as to_s but without the currency symbol
    def to_s_short(sep='.')
      
      if currency.places > 0
        str =  sprintf("%03d", to_cents)
      "#{str[0..-(currency.places+1)]}#{sep}#{ str[-currency.places..-1] }"
      else
        sprintf("%01d", to_cents)
      end
    end
    
    # compare two money values
    def <=>(other)
      raise "invalid comparison of different categories" unless code == other.code
      amount <=> other.amount
    end
    
    # are two money values equal ?
    def ==(other)
      return unless other.kind_of? Money
       (code == other.code) && (amount == other.amount)
    end
    
    # inspect 
    def inspect
      to_s
    end
    
    
    private 
    
    def check_valid(other)
      raise "currency types do not match #{other.code} != #{code}" if (other.code != code)
    end
    
  end
end