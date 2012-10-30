module Commerce
  ########################################################################
  # the Price class combines a Money value with a Tax value.
  #
  ########################################################################
  class Price
    
    include Comparable
    
    # initialize with an value of Money and
    # with an (optional) amount of Tax
    def initialize(amt, tx=nil)
      raise ArgumentError, "invalid tax amount" unless amt.kind_of? Money
      raise ArgumentError, "invalid tax rate"   if tx && ! tx.kind_of?( Tax)
      @money = amt
      @tax = tx
    end
    
    
    
    def to_places(places)
      self.class.new( money.to_places(places),tax && tax.to_places(places))
    end
    
    # the bruto ( including tax) amount of money
    def money
      @money
    end
    
    def amount
      money && money.amount
    end
    
    def incl_tax
      money
    end
    
    # the tax object
    def tax
      @tax
    end
    
    # the currency code
    def code
      money && money.code
    end
    
    # the currency of the money
    def currency
      money && money.currency 
    end
    
    # an array of all the taxes
    def taxes
      tax && tax.taxes  
    end
    
    # the netto ( excluding tax) amount of money
    def excl_tax
      if tax
        money - tax.money
      else
        money
      end
    end
    
    
    # create a price while supplying an amount(number), currency 
    def self.new_with_curr(amount,curr)
      amt = Money.new(amount,curr)
      Price.new( amt )
    end
    
    # create a price while supplying an amount(number), currency and tax 
    # rate.
    def self.new_with_curr_and_rate(amount,curr,rate=nil)
      amt = Money.new(amount,curr)
      new_with_rate(amt,rate)
    end
    
    # create a price while supplying a money (netto) value and tax 
    # rate.
    def self.new_with_rate(money,rate=nil )
      tx = rate && Tax.new( (money*rate.incl_rate),rate)
      Price.new( money, tx )
    end
    
    # create a price while supplying a money (ex tax) value and tax 
    # rate.
    def self.new_excl_with_rate(money,rate=nil )
      tx = Tax.new( (money*rate.rate),rate) if rate
      Price.new( money + tx.money, tx )
    end
    
    # negate a price
    def -@
      Price.new( (money * -1 ) ,(tax && (tax * -1) ) ) 
    end
    
    # add two prices
    def +(other)
      Price.new( (money + other.money) , taxsum(tax, other.tax)  )
    end
    
    # minus a price
    def -(other)
      othertax = - other.tax if other.tax # can be nil
      Price.new( (money - other.money) , taxsum(tax, othertax) )
    end
    
    # multiply a price by a number
    def *(op)
      Price.new( (money * op ) ,(tax && (tax * op) ) ) 
    end
    
    # divide a price by a number
    def /(op)
      if op==0
        raise "attemp to divide by zero !! "
      end
      Price.new( ( money / op ) , (tax && (tax / op) ) )
    end
    
    # convert to float
    def to_f
     (money).to_f
    end
    
    # convert to integer
    def to_cents
     (money).to_cents
    end
    
    # convert to string
    def to_s
      money.to_s
    end
    
    # convert to string ( no currency symbol )
    def to_s_short
      money.to_s_short
    end
    
    # compare price values
    def <=>(other)
      money <=> other.money
    end
    
    # are prices equal ?
    def ==(other)
      return unless other.kind_of? Price
      if (!tax && other.tax && (other.tax.to_cents == 0)) ||
       (!other.tax && tax && (tax.to_cents == 0))
       (money == other.money)
      else
       (money == other.money) && (tax == other.tax)
      end
      
    end
    
    # inspect
    def inspect
      to_s
    end
    
    alias_method :netto, :excl_tax
    alias_method :bruto, :incl_tax
    alias_method :gross, :incl_tax
    alias_method :net,   :excl_tax
    
    protected
    
    # assign tax value
    def tax=(t)
      @tax=t
    end
    
    # assign money value
    def money=(a)
      @money=a
    end
    
    private
    
    # algorithm for adding two taxes
    def taxsum(a,b)
      if a && b
        a + b
      elsif a
        a
      elsif b
        b
      else
        nil
      end
    end
    
  end
  
end