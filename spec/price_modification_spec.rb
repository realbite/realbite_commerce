# encoding: utf-8 
$KCODE = "UTF-8" if RUBY_VERSION < "1.9"
require "spec_helper"

describe "price modifidation" do
  
  before do
    @m106 = Commerce::Money.new(106,:eur)
    @laag = Commerce::TaxRate.new('L',0.06)
    @hoog = Commerce::TaxRate.new('H',0.19)
    @p1    = Commerce::Price.new(Commerce::Money.new(1.06,:eur),Commerce::Tax.new(Commerce::Money.new(0.06,:eur),@laag))
    @p2 = Commerce::Price.new(Commerce::Money.new(1.19,:eur),Commerce::Tax.new(Commerce::Money.new(0.19,:eur),@hoog))
    @p3 = Commerce::Price.new(Commerce::Money.new(11900,:eur),Commerce::Tax.new(Commerce::Money.new(1900,:eur),@hoog))
    @p0 = Commerce::Price.new(Commerce::Money.new(0,:eur),nil)
  end
  describe "create" do
    it "should be valid" do
      lambda{Commerce::PriceModification.new(12,true)}.should_not raise_error
      lambda{Commerce::PriceModification.new(12,false)}.should_not raise_error
    end
  end
  
  describe "apply a modifiaction" do
    it "should apply a percentage" do
      mod = Commerce::PriceModification.new(10,true)
      mod.apply(@p1).excl_tax.to_f.should == 1.1
      mod.apply(@p2).excl_tax.to_f.should == 1.1
      mod.apply(@p3).excl_tax.to_f.should == 11000
      mod.apply(@p0).excl_tax.to_f.should == 0
    end
    
    it "should apply an amount" do
      mod = Commerce::PriceModification.new(1.19,false)
      mod.apply(@p2).excl_tax.to_f.should == 2
      mod.apply(@p3).excl_tax.to_f.should == 10001
      mod.apply(@p0).incl_tax.to_f.should == 1.19
      mod.apply(@p0).incl_tax.to_f.should == 1.19
    end
  end
end