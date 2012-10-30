module Commerce
  
  ########################################################################
  # Tax class - the hard stuff
  #
  # the Tax class stores an amount of tax. This consists of an amount of money
  # and a given taxrate.
  ########################################################################  
  
  class Tax
    
    include Comparable
    
    attr_accessor :money, :rate
    
    # initialize with a money value and a tax rate.
    def initialize(amt,rate)
      raise ArgumentError, "invalid tax amount" unless amt.kind_of? Money
      raise ArgumentError, "invalid tax rate"   unless rate.kind_of? TaxRate
      @money = amt
      @rate = rate
    end
    
    # calculate what the original amount must have been from the tax value
    # and the tax rate.
    def principal
      @money / @rate.rate if @rate.rate > 0
    end
    
    # add two tax values - creating a compound tax value if the rates are 
    # different
    def +(other)
      if rate == other.rate
        self.class.new( (money + other.money) , @rate )
      else
        CompoundTax.new( self,other)
      end
    end
    
    # minus a tax value
    def -@
      self.class.new( - money, @rate )
    end
    
    # sutract two tax values.
    def -(other)
      if rate == other.rate
        self.class.new( (money - other.money) , @rate )
      else
        CompoundTax.new( self,-other)
      end
    end
    
    # multiply a tax value by a number
    def *(op)
      self.class.new( (money * op ) ,@rate ) 
    end
    
    # divide a tax value by a number
    def /(op)
      if op==0
        raise "attempt to divide Tax by zero !! "
      end
      self.class.new( ( @money / op ), @rate )
    end
    
    # convert to float 
    def to_f
     (@money).to_f
    end
    
    def amount
      money && money.amount
    end
    
    # round the tax amount to the number of places.
    def to_places(places)
      self.class.new(money.to_places(places)  , @rate )
    end
    
    # convert to integer
    def to_cents
     (@money).to_cents
    end
    
    # convert to string
    def to_s
      "#{@rate} #{money}"
    end
    
    # compare two tax values just on the money value
    def <=>(other)
      money <=> other.money
    end
    
    # two tax values are equal if they have the same values and the
    # same rates.
    def ==(other)
      return unless other.kind_of? Tax
       (rate == other.rate) && (money == other.money)
    end
    
    # return an array of all the individual taxes which go into this 
    # tax
    def taxes
      [self]
    end
    
    # inspect
    def inspect
      to_s
    end
    
    # convert tax object to a string format
    def to_db
      str =""
      taxes.each do |t|
        str += "#{t.money.amount.to_s('F') }/#{t.rate.code}/#{t.rate.rate};"
      end
      str
    end
    
    # create a tax object from string format
    def self.new_from_db_with_curr( str, curr )
      return nil unless str && curr
      fields = str[0..-2].split(';')
      res = nil
      fields.each do |substr|
        subfields = substr.split('/')
        rate = TaxRate.new(subfields[1],subfields[2])
        amt  = Money.new(subfields[0], curr)
        t = Tax.new( amt , rate  )
        if res
          res = res + t
        else
          res = t
        end
      end
      res
    end
    
    def type
      rate
    end
    
    def type=(val)
      rate=val
    end
    
  end # Tax
  
  ########################################################################
  # TaxRateHash holds a list of TaxRates with their corresponding 
  # values. Ensure that elements are chosen according to their code only
  ########################################################################
  class TaxRateHash < Hash
    def [](key)
      each{ |k,v| return v if k.to_s == key.to_s}
      nil
    end
    
    def []=(key,value)
      find_key=nil
      each{ |k,v| (find_key=k;break) if k.to_s == key.to_s}
      find_key ||= key
      store(find_key,value)
      value
    end
    
    # remove taxes with 0 amounts.
    def rationalize
      each{ |k,v| delete(k) if v.to_cents==0}
    end
  end
  
  ########################################################################
  # the CompoundTax Class is derived from the Tax Class, A Tax Value with
  # multiple tax rates is stored as a CompundTax. The individual tax components
  # are stored within the CompundTax 
  ########################################################################
  class CompoundTax < Tax
    
    COMPOUND_CODE = "*"
    
    # create new CompoundTax from a list of taxes
    #
    def initialize(*args)
      @list = TaxRateHash.new
      @money = nil
      @rate = TaxRate.new_with_code_and_rate(COMPOUND_CODE)
      args.each do |txes|
        txes.taxes.each do |tx| 
          @list[tx.rate] = @list[tx.rate] ?   @list[tx.rate] + tx.money :  tx.money
          @money = @money ? @money + tx.money : tx.money
        end
      end
      @list.rationalize
    end
    
    
    # add two compound taxes together
    #
    def +(other)
      ct = CompoundTax.new
      ct.money = money + other.money
      l = TaxRateHash.new
      if other.rate == @rate
        other_list = other.list.dup
        @list.each do |k,v|
          l[k] = v + other.list[k] if other_list.delete(k)
        end
        other_list.each{|k,v| l[k] = other.list[k] }
      else
        l = @list.dup
        l[other.rate] = l[other.rate] ? ( l[other.rate] + other.money) : other.money
      end
      ct.list = l #.rationalize
      ct
    end
    
    # minus a compound taxes
    def -@
      ct = CompoundTax.new
      ct.money = - money
      l = TaxRateHash.new
      @list.each do |k,v|
        l[k] = -v 
      end
      ct.list = l
      ct
    end
    
    # subtract two compound taxes
    def -(other)
      ct = CompoundTax.new
      ct.money = money - other.money
      l = TaxRateHash.new
      if other.rate == @rate
        other_list = other.list.dup
        @list.each do |k,v|
          l[k] = v - other.list[k] if other_list.delete(k)
        end
        other_list.each{|k,v| l[k] = -other.list[k] }
      else
        l = @list.dup
        l[other.rate] = l[other.rate] ? ( l[other.rate] - other.money) : other.money
      end
      ct.list = l #.rationalize
      ct
    end
    
    # round the tax amount to the number of places.
    def to_places(places)
      ct = CompoundTax.new
      ct.money = money.to_places(places)
      l = TaxRateHash.new
      @list.each do |k,v|
        l[k] = v.dup 
      end
      ct.list = l
      ct
    end
    
    # multiply a compound tax by a number
    def *(op)
      ct = CompoundTax.new
      ct.money = money * op
      l = TaxRateHash.new
      @list.each do |k,v|
        l[k] = v * op
      end
      ct.list = l
      ct
    end
    
    # divide a compound tax by a number
    def /(op)
      if op==0
        raise "attempt to divide Tax by zero !! "
      end
      ct = CompoundTax.new
      ct.money = money / op
      l = TaxRateHash.new
      @list.each do |k,v|
        l[k] = v / op
      end
      ct.list = l
      ct
    end
    
    # return an array of individual taxes within the compound tax    
    def taxes
      a = []
      @list.each{|k,v| a<< Tax.new(v,k)}
      a
    end
    
    def taxes=(val)
      @list = TaxRateHash.new
      return unless val
      val.each{|v| @list[v.rate] = v.money}
    end
    
    protected
    
    def list
      @list
    end
    
    def list=(l)
      @list=l
    end
    
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