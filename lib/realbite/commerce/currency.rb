# encoding: utf-8 
# 
# derive your Currency and TaxRate class from these
#
# Currency < Commerce::Currency
# TaxRate  < Commerce::TaxRate
$KCODE = "UTF-8" if RUBY_VERSION < "1.9"
module Commerce
  
  ########################################################################
  # Currency class - hold currency info - name, symbol
  # eg Euro - EUR - E
  #    Pound - GBP - 
  #    Dollar - USD - $
  # handle currency by its smallest unit
  ########################################################################
  class Currency
    
    attr_accessor :name
    attr_accessor :description
    attr_accessor :code
    attr_accessor :symbol
    attr_accessor :cent_name
    attr_accessor :cent_symbol
    
    def self.insert(name,curr_code,symbol,cent_name,cent_symbol)
      raise ArgumentError,"missing currency code" unless curr_code && !curr_code.empty?
      curr_code = curr_code.upcase
      hash_list[curr_code] =  Currency.new(name,curr_code,symbol) unless Currency.find(curr_code)
      hash_list[curr_code].cent_name   = cent_name
      hash_list[curr_code].cent_symbol = cent_symbol
      hash_list[curr_code].places = 0 unless (cent_name ||cent_symbol) 
    end
    
    def self.copy(other)
      self.new(other.name, other.code, other.symbol)
    end
    
    def Currency.hash_list
      @list ||={}
    end
    
    def self.list
      hash_list.values
    end
    
    def self.all
      list
    end
    
    def id
      code
    end
    
    def self.to_select_list
      list.map{|i| [i.symbol,i.code]}
    end
    
    # find a given currency code passed as a string or as a symbol
    def self.find(code)
      hash_list[code.to_s.upcase]
    end
    
    def initialize(name,code,symbol=nil)
      raise ArgumentError, "invalid currency code: #{code}" unless code =~ /^[A-Z]{3,3}$/
      @name = name
      @code = code 
      @symbol = symbol || code || name
      @multiplier = 100
      @places = 2
      @description = @name
      @cent_name = nil
      @cent_symbol = nil
    end
    
    def places
      @places
    end
    
    def places=(p)
      p = p.to_i
      if (p < 4) &&  (p >= 0) 
        @places = p
        m = 1
        p.times{ m= m*10} 
        @multiplier = m
      else
        raise "invalid value for currency decimal places "
      end
    end
    
    def multiplier
      @multiplier
    end
    
    def ==(other)
      if other.kind_of? Currency
        code == other.code
      else
        false
      end
    end
    
    def to_s
      code
    end
    
    def inspect
      to_s
    end
    
    def label
      @symbol
    end
  end
  
  Currency.insert("us dollar","USD","$","cent","¢")
  Currency.insert("euro","EUR","€","cent","c")
  Currency.insert("british pound","GBP","£","pence","p")
  Currency.insert("japanese yen","JPY","¥",nil,nil)
  Currency.insert("chinese yuan","CNY","元",nil,nil)
end