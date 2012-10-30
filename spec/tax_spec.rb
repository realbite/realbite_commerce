# encoding: utf-8 
$KCODE = "UTF-8" if RUBY_VERSION < "1.9"
require "spec_helper"

describe "tax" do
  
  before do
    @laag = Commerce::TaxRate.new('L',0.06)
    @hoog = Commerce::TaxRate.new('H',0.19)
    @hoog2 = Commerce::TaxRate.new('H',0.20)
    @zero = Commerce::TaxRate.new('Z',0)
    @xtra = Commerce::TaxRate.new('X',0.5)
    
    @a = Commerce::Money.new(100,:eur)
    @a_laag = Commerce::Money.new(106,:eur)
    @a_hoog = Commerce::Money.new(119,:eur)
  end
  
  describe "create new tax amount" do
    it "should be valid" do
      Commerce::Tax.new(@a,@laag).money.amount.should == 100
      Commerce::Tax.new(@a,@laag).rate.code.should == "L"
      lambda{Commerce::Tax.new(12,@laag)}.should raise_error
      lambda{Commerce::Tax.new(@a,"L")}.should raise_error
      lambda{Commerce::TaxRate.new("L0")}.should_not raise_error
      lambda{Commerce::TaxRate.new("l0")}.should_not raise_error
      lambda{Commerce::TaxRate.new("L/")}.should raise_error
    end
    
    it "should compare two tax rates" do
      Commerce::TaxRate.new('H',0.19).should == Commerce::TaxRate.new('H',0.19)
      Commerce::TaxRate.new('H',0.19).should_not == Commerce::TaxRate.new('H',0.21)
      Commerce::TaxRate.new('H',0.19).should_not == Commerce::TaxRate.new('L',0.19)
    end
  end
  
  describe "perform arithmetic" do
    before do
      @t_100_l = Commerce::Tax.new(@a,@laag)
      @t_106_l = Commerce::Tax.new(@a_laag,@laag)
      @t_119_h = Commerce::Tax.new(@a_hoog,@hoog)
    end
    
    it "should compare values" do
      @t_100_l.should == @t_100_l
      @t_100_l.should < @t_106_l
      @t_106_l.should > @t_100_l
      [@t_106_l,@t_119_h,@t_100_l].sort.should == [@t_100_l,@t_106_l,@t_119_h]
    end
    
    it "should add two similar taxes" do
     (@t_100_l + @t_100_l).money.amount.should == 200
     (@t_100_l + @t_100_l).taxes.length.should == 1
     (@t_100_l + @t_100_l).rate.code.should == 'L'
     (@t_100_l + @t_106_l).money.amount.should == 206
     (@t_100_l + (@t_106_l + @t_100_l)).should == ((@t_100_l + @t_106_l) + @t_100_l)
    end
    
    it "should subtract two similar taxes" do
     (@t_106_l - @t_100_l).money.amount.should == 6
     (@t_100_l - @t_100_l).rate.code.should == 'L'
     (@t_106_l - @t_100_l).taxes.length.should == 1
     (@t_100_l - @t_106_l).money.amount.should == -6
     (@t_100_l - @t_100_l).money.amount.should == 0
     (@t_100_l - @t_100_l).taxes.length.should == 1
   end
   
   it "should add a compound and a simple tax" do
     t1 = Commerce::Tax.new( Commerce::Money.new(14,:eur), @hoog)
     t2 = Commerce::Tax.new( Commerce::Money.new(3,:eur), @laag)
     t3 = Commerce::Tax.new( Commerce::Money.new(7,:eur), @xtra)
     compound1 = t1 + t2
     sum1      = compound1 + t3
     sum1.money.amount.should == 24
   end
   
   it "should add two compound taxes" do
     t1 = Commerce::Tax.new( Commerce::Money.new(14,:eur), @hoog)
     t2 = Commerce::Tax.new( Commerce::Money.new(3,:eur), @laag)
     t3 = Commerce::Tax.new( Commerce::Money.new(7,:eur), @xtra)
     compound1 = t1 + t2
     compound2 = t1 + t3
     sum1      = compound1 + compound2
     sum1.money.amount.should == 38
   end
    
    
    
    it "should multiply taxes" do
     (@t_100_l * 2.5).money.amount.should == 250
     ((@t_100_l + @t_106_l)*3).should == ((@t_100_l*3) + (@t_106_l*3))
    end
    
    it "should add  dissimilar taxes" do
      sum = (@t_106_l + @t_119_h)
      sum.money.amount.should == 225
      sum.rate.code.should == '*'
      sum.taxes.length.should == 2
      if sum.taxes[0].money.amount == 106
        sum.taxes[1].money.amount.should == 119
      else
        sum.taxes[1].money.amount.should == 106 
        sum.taxes[0].money.amount.should == 119 
      end
    end
    
    it "should add  taxes with same code and different rates" do
      rate1 = Commerce::TaxRate.new('H',0.19)
      rate2 = Commerce::TaxRate.new('H',0.21)
      amount1 = Commerce::Tax.new( Commerce::Money.new(14,:eur), rate1)
      amount2 = Commerce::Tax.new( Commerce::Money.new(14,:eur), rate2)
      sum = (amount1 + amount2)
      sum.money.amount.should == 28
      sum.rate.code.should == '*'
      sum.taxes.length.should == 2
    end
    
    
    it "should subtract  dissimilar taxes" do
      sum = (@t_106_l - @t_119_h)
      sum.money.amount.should == -13
      sum.rate.code.should == '*'
      sum.taxes.length.should == 2
      if sum.taxes[1].money.amount == 106
        sum.taxes[0].money.amount.should == -119 
        sum.taxes[1].money.amount.should == 106 
      else
        sum.taxes[1].money.amount.should == -119 
        sum.taxes[0].money.amount.should == 106 
      end
    end
    
    it "should subtract a compound and a simple tax" do
     t1 = Commerce::Tax.new( Commerce::Money.new(14,:eur), @hoog)
     t2 = Commerce::Tax.new( Commerce::Money.new(3,:eur), @laag)
     t3 = Commerce::Tax.new( Commerce::Money.new(7,:eur), @xtra)
     compound1 = t1 + t2
     sum1      = compound1 - t3
     sum1.money.amount.should == 10
   end
   
   it "should subtract two compound taxes" do
     t1 = Commerce::Tax.new( Commerce::Money.new(14,:eur), @hoog)
     t2 = Commerce::Tax.new( Commerce::Money.new(3,:eur), @laag)
     t3 = Commerce::Tax.new( Commerce::Money.new(7,:eur), @xtra)
     compound1 = t1 + t2
     compound2 = t1 + t3
     sum1      = compound1 - compound2
     sum1.money.amount.should == -4
   end
   
#   it "should rationalize compound taxes" do
#     t1 = Commerce::Tax.new( Commerce::Money.new(14,:eur), @hoog)
#     t2 = Commerce::Tax.new( Commerce::Money.new(3,:eur), @laag)
#     t3 = Commerce::Tax.new( Commerce::Money.new(7,:eur), @xtra)
#     compound = t1 + t2 - t1
#     compound.taxes.length.should == 1
#     compound = t1 + t2 - t1 - t2
#     compound.taxes.length.should == 0
#     compound = compound + t3
#     compound.taxes.length.should == 1
#     compound.money.amount.should == 7
#   end
  end
  
  describe "derive values" do
    before do
      @tax = Commerce::Tax.new(Commerce::Money.new(6,:eur),@laag)
    end
    
    it "should calculate the principal amount" do
      @tax.principal.amount.should == 100
    end
  end
  
  describe "store values" do
    before do
      @tax = Commerce::Tax.new(Commerce::Money.new(6,:eur),@laag)
      @tax2 = Commerce::Tax.new(Commerce::Money.new(130.7856,:eur),@hoog)
    end
    
    it "should convert taxes to a string" do
      @tax.to_db.should == "6.0/L/0.06;"
      @tax2.to_db.should == "130.7856/H/0.19;"
    end
    
    it "should load taxes from a string" do
      Commerce::Tax.new_from_db_with_curr("6.0/L/0.06;",:eur).should == @tax
      Commerce::Tax.new_from_db_with_curr("130.7856/H/0.19;",:eur).should == @tax2
    end
    
    it "should dump/load taxes" do
      str = (@tax + @tax2 + @tax).to_db
      Commerce::Tax.new_from_db_with_curr(str,:eur).should == @tax*2 + @tax2
    end
  end
  
  describe "round values" do
    it " should round simple taxes" do
      Commerce::Tax.new(Commerce::Money.new(6.1234567,:eur),@laag).to_places(3).amount.should == 6.123
      Commerce::Tax.new(Commerce::Money.new(6.1234567,:eur),@laag).to_places(4).amount.should == 6.1235
    end
    
    it " should round compound taxes" do
      c1 = Commerce::Tax.new(Commerce::Money.new(3.123,:eur),@laag)
      c2 = Commerce::Tax.new(Commerce::Money.new(3.0004567,:eur),@hoog)
       (c1 + c2).to_places(3).amount.should == 6.123
       (c1 + c2).to_places(4).amount.should == 6.1235
    end
  end
  
  
end