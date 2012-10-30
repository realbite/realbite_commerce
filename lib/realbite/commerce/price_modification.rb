module Commerce
  ########################################################################
  # PriceModification stores an amount ( absolute or percentage) by which
  # a price can be modified and uses these values to calculate a new price
  #
  ########################################################################
  
  class PriceModification
    attr_accessor :percent
    attr_accessor :amount
    
    # create a modification with an amount (number) and a flag whether this
    # number is a percentage ( true [default] ) or absolute ( false )
    def initialize(amt,pc=true)
      @percent = pc
      @amount=amt.to_f
    end
    
    # is a percentage modification ? 
    def percent?
      @percent == true
    end
    
    # return the price calculated by applying
    # this modification to the given price
    def apply( price)
      raise ArgumentError,"invalid price" unless price.kind_of? Price
      if @percent
        if price.to_cents == 0
          price
        else
         ( price * ( @amount + 100 ) ) / 100
        end
      else
        if price.to_cents == 0
          Price.new( Money.new( @amount, price.currency))
        else
          mult = ( (@amount) * 1000.0 * price.currency.multiplier ) / price.to_cents # mult by 1000 to improve accuracy
          abs = (price * mult) / 1000.0
          price + abs
        end
      end
    end
  end
  
end #Commerce