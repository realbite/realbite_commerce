# encoding: utf-8 
$KCODE = "UTF-8" if RUBY_VERSION < "1.9"
require "spec_helper"


describe "price" do
  
  before do
    @m106 = Commerce::Money.new(106,:eur)
    @laag = Commerce::TaxRate.new('L',0.06)
    @hoog = Commerce::TaxRate.new('H',0.19)
    @t6   = Commerce::Tax.new(Commerce::Money.new(6,:eur),@laag)
  end
  
  describe "create" do
    it "should be valid" do
      lambda{Commerce::Price.new(@m106,nil)}.should_not raise_error
      lambda{Commerce::Price.new(@m106,@t6)}.should_not raise_error
      lambda{Commerce::Price.new(12,nil)}.should raise_error
      Commerce::Price.new(@m106,nil).currency.code.should == "EUR"
      Commerce::Price.new(Commerce::Money.new(6.125,:eur),@t6).to_f.should == 6.125
      Commerce::Price.new(Commerce::Money.new(6.135,:eur),@t6).to_cents.should == 614
    end
  end
  
  describe "derive values" do
    it "should have netto amount" do
      Commerce::Price.new(@m106,@t6).excl_tax.amount.should == 100
      Commerce::Price.new(@m106,nil).excl_tax.amount.should == 106
    end
    
    it "should have bruto amount" do
      Commerce::Price.new(@m106,@t6).incl_tax.amount.should == 106
      Commerce::Price.new(@m106,nil).incl_tax.amount.should == 106
    end
    
    it "should have tax amount" do
      Commerce::Price.new(@m106,@t6).tax.money.amount.should == 6
      Commerce::Price.new(@m106,nil).tax.should == nil
    end
  end
  
  describe "comparison" do
    it "should be equal if prices are the same" do
      Commerce::Price.new(@m106,@t6).should == Commerce::Price.new(@m106,@t6)
      Commerce::Price.new(@m106,nil).should == Commerce::Price.new(@m106,nil)
    end
    
    it "should be equal if the tax part is 0 or nil" do
      Commerce::Price.new(@m106,(@t6-@t6)).should == Commerce::Price.new(@m106,nil)
    end
  end
  
  describe "arithmetic" do
    before do
      @p1 = Commerce::Price.new(Commerce::Money.new(1.06,:eur),Commerce::Tax.new(Commerce::Money.new(0.06,:eur),@laag))
      @p2 = Commerce::Price.new(Commerce::Money.new(1.19,:eur),Commerce::Tax.new(Commerce::Money.new(0.19,:eur),@hoog))
      @p3 = Commerce::Price.new(Commerce::Money.new(11900,:eur),Commerce::Tax.new(Commerce::Money.new(1900,:eur),@hoog))
      @zero = Commerce::Price.new(Commerce::Money.new(0,:eur))
    end
    
    it "should add prices" do
     (@p1 + @p1).should == @p1 * 2
     ((@p1 + @p2) + @p3).should == (@p1 + (@p2 + @p3))
     ((@p1 + @p2) + @p3).excl_tax.amount.should == 10002
     ((@p1 + @p2) + @p3).tax.money.amount.should == 1900.25
    end
    
    it "should subtract prices" do
     (@p1 - @p1).excl_tax.amount.should == 0
     (@p1 - @p2).excl_tax.amount.should == 0
     (@p1 - @p2).incl_tax.amount.should == -0.13
     (@p1 - @p2).tax.money.amount.should == -0.13
     (@zero-@zero).should == @zero
   end
   
   it "should multiply prices by an amount" do
     p1 = Commerce::Price.new(Commerce::Money.new(2.4,:eur),Commerce::Tax.new(Commerce::Money.new(0.19,:eur),@hoog))
     (p1 * 9).amount.should == 21.6
     (p1 * 9.0).amount.should == 21.6
     (p1 * -9).amount.should == -21.6
     (p1 * -9.0).amount.should == -21.6
   end
  end
  
  it "should round prices values to given number of places" do
    Commerce::Price.new(Commerce::Money.new(12345.12345,"eur")).to_places(1).should == Commerce::Price.new(Commerce::Money.new(12345.1,"eur"))
    Commerce::Price.new(Commerce::Money.new(12345.12345,"eur")).to_places(2).should == Commerce::Price.new(Commerce::Money.new(12345.12,"eur"))
    Commerce::Price.new(Commerce::Money.new(12345.12345,"eur")).to_places(3).should == Commerce::Price.new(Commerce::Money.new(12345.123,"eur"))
    Commerce::Price.new(Commerce::Money.new(12345.12345,"eur")).to_places(4).should == Commerce::Price.new(Commerce::Money.new(12345.1234,"eur"))
    Commerce::Price.new(Commerce::Money.new(12345.12345,"eur")).to_places(5).should == Commerce::Price.new(Commerce::Money.new(12345.12345,"eur"))
    Commerce::Price.new(Commerce::Money.new(12345.12345,"eur")).to_places(6).should == Commerce::Price.new(Commerce::Money.new(12345.12345,"eur"))
    Commerce::Price.new(Commerce::Money.new(12345.12345,"eur")).to_places(7).should == Commerce::Price.new(Commerce::Money.new(12345.12345,"eur"))
    Commerce::Price.new(Commerce::Money.new(12345.123456,"eur")).to_places(7).should == Commerce::Price.new(Commerce::Money.new(12345.123456,"eur"))
    Commerce::Price.new(Commerce::Money.new(12345.123456,"eur")).to_places(5).should == Commerce::Price.new(Commerce::Money.new(12345.12346,"eur"))
    Commerce::Price.new(Commerce::Money.new(12345.123455,"eur")).to_places(5).should == Commerce::Price.new(Commerce::Money.new(12345.12346,"eur"))
  end
  
  it "should create from a excl_tax amount with a tax rate" do
    amt = Commerce::Money.new(17.5,:eur)
    p = Commerce::Price.new_excl_with_rate(amt,@hoog )
    p.amount.should == 20.825
    p.to_f.should == 20.825
  end
end