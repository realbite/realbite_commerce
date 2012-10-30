# encoding: utf-8 
$KCODE = "UTF-8" if RUBY_VERSION < "1.9"
require "spec_helper"

describe "money" do
  describe "can create money" do
    it "should be valid" do
      lambda{Commerce::Money.new(12,"eur")}.should_not raise_error
      lambda{Commerce::Money.new(12,:eur)}.should_not raise_error
      lambda{Commerce::Money.new(12,"")}.should raise_error
      lambda{Commerce::Money.new(12,nil)}.should raise_error
      lambda{Commerce::Money.new(12,"euro")}.should raise_error
    end
    
    it "should have an amount" do
      Commerce::Money.new(12,"eur").amount.should     == 12
      Commerce::Money.new("12","eur").amount.should   == 12
      Commerce::Money.new(12.5,"eur").amount.should   == 12.5
      Commerce::Money.new("12.5","eur").amount.should == 12.5
      Commerce::Money.new(1234567890.1234,"eur").amount.should == 1234567890.1234
    end
    
    it "should also accept a currency object" do
      euro = Commerce::Currency.find :eur
      Commerce::Money.new(12,euro).amount.should     == 12
      Commerce::Money.new("12",euro).code.should   == "EUR"
    end
  end
  
  describe "can do money arithmetic" do
    before do
      @a = Commerce::Money.new(12,"eur")
      @b = Commerce::Money.new(100,"eur")
      @c = Commerce::Money.new(10000000,"EUR")
      @x = Commerce::Money.new(100,"usd")
      @l1 = Commerce::Money.new(1234567890.1234,"eur")
      @l2 = Commerce::Money.new(1234567890.1235,"eur")
    end
    
    it "should add two monies" do
      (@a + @b).should == Commerce::Money.new(112,"eur")
      (@a + @b).amount.should == 112
      (@a + @b).code.should == "EUR"
      lambda{@a + @x}.should raise_error
      (@l1 + @l2).should == Commerce::Money.new(2469135780.2469,"eur")
    end
    
    it "should be accumulative" do
      (@a + (@b + @c)).should == ((@a+@b) + @c)
    end
    
    it "should subtract monies" do
      (@a - @b).amount.should == -88
      (@b - @a).amount.should == 88
      (@a - @b).code.should == "EUR"
      lambda{@a - @x}.should raise_error
      (@l1 - @l1).should == Commerce::Money.new(0,"eur")
      (@l2 - @l1).should == Commerce::Money.new(0.0001,"eur")
    end
    
    it "should multiply money" do
     (@a * 2).should == ( @a + @a )
     (@b * 12.12).amount.should == 1212
     (@c * 0.0000001).amount.should == 1
     (@x * 2).should == ( @x + @x )
      p1 = Commerce::Money.new(2.4,:eur)
       (p1 * 9).amount.should == 21.6
       (p1 * 9.0).amount.should == 21.6
       (p1 * -9).amount.should == -21.6
       (p1 * -9.0).amount.should == -21.6
    end
    
    it "should be commutative" do
      ((@a + @b) * 12.67).should == (@a*12.67) + (@b*12.67)
    end
    
  end
  
  describe "display as a string" do
    it "should have correct decimal places" do
      Commerce::Money.new(12345.12345,"eur").to_s.should == "€ 12345.12"
      Commerce::Money.new(12,"eur").to_s.should == "€ 12.00"
      Commerce::Money.new(12.12,"jpy").to_s.should == "¥ 12"
      Commerce::Money.new(12.51,"jpy").to_s.should == "¥ 13"
    end
  end
  
  describe "convert to other classes" do
    it "should convert to a float without rounding" do
      Commerce::Money.new(12345.12345,"eur").to_f.should == 12345.12345
      Commerce::Money.new(12,"eur").to_f.should == 12.0
    end
    
    it "should convert to cents as integer" do
      Commerce::Money.new(12345.12345,"eur").to_cents.should == 1234512
      Commerce::Money.new(12,"eur").to_cents.should == 1200
    end
    
    it "should round values to number of places" do
      Commerce::Money.new(12345.12345,"eur").round.should == 12345.12
      Commerce::Money.new(12345.12545,"eur").round.should == 12345.13
      Commerce::Money.new(12345.125,"eur").round.should == 12345.12
      Commerce::Money.new(12345.135,"eur").round.should == 12345.14
      Commerce::Money.new(12345.125001,"eur").round.should == 12345.13
      Commerce::Money.new(12.51,"jpy").round.should == 13
      Commerce::Money.new(12.5,"jpy").round.should == 12
      Commerce::Money.new(13.5,"jpy").round.should == 14
      Commerce::Money.new(12.49,"jpy").round.should == 12
    end
    
    it "should round negative values to number of places" do
      Commerce::Money.new(-12345.12345,"eur").round.should == -12345.12
      Commerce::Money.new(-12345.12545,"eur").round.should == -12345.13
      Commerce::Money.new(-12345.125,"eur").round.should == -12345.12
      Commerce::Money.new(-12345.135,"eur").round.should == -12345.14
      Commerce::Money.new(-12345.125001,"eur").round.should == -12345.13
      Commerce::Money.new(-12.51,"jpy").round.should == -13
      Commerce::Money.new(-12.5,"jpy").round.should == -12
      Commerce::Money.new(-13.5,"jpy").round.should == -14
      Commerce::Money.new(-12.49,"jpy").round.should == -12
    end
    
    it "should round bigdecimal values to given number of places" do
      Commerce::Money.new(12345.12345,"eur").amount.to_places(1).should == 12345.1
      Commerce::Money.new(12345.12345,"eur").amount.to_places(2).should == 12345.12
      Commerce::Money.new(12345.12345,"eur").amount.to_places(3).should == 12345.123
      Commerce::Money.new(12345.12345,"eur").amount.to_places(4).should == 12345.1234
      Commerce::Money.new(12345.12345,"eur").amount.to_places(5).should == 12345.12345
      Commerce::Money.new(12345.12345,"eur").amount.to_places(6).should == 12345.12345
      Commerce::Money.new(12345.12345,"eur").amount.to_places(7).should == 12345.12345
      Commerce::Money.new(12345.123456,"eur").amount.to_places(7).should == 12345.123456
      Commerce::Money.new(12345.123456,"eur").amount.to_places(5).should == 12345.12346
      Commerce::Money.new(12345.123455,"eur").amount.to_places(5).should == 12345.12346
    end
    
    it "should round negative bigdecimal values to given number of places" do
      Commerce::Money.new(-12345.12345,"eur").amount.to_places(1).should == -12345.1
      Commerce::Money.new(-12345.12345,"eur").amount.to_places(2).should == -12345.12
      Commerce::Money.new(-12345.12345,"eur").amount.to_places(3).should == -12345.123
      Commerce::Money.new(-12345.12345,"eur").amount.to_places(4).should == -12345.1234
      Commerce::Money.new(-12345.12345,"eur").amount.to_places(5).should == -12345.12345
      Commerce::Money.new(-12345.12345,"eur").amount.to_places(6).should == -12345.12345
      Commerce::Money.new(-12345.12345,"eur").amount.to_places(7).should == -12345.12345
      Commerce::Money.new(-12345.123456,"eur").amount.to_places(7).should == -12345.123456
      Commerce::Money.new(-12345.123456,"eur").amount.to_places(5).should == -12345.12346
      Commerce::Money.new(-12345.123455,"eur").amount.to_places(5).should == -12345.12346
    end
    
    it "should round money values to given number of places" do
      Commerce::Money.new(12345.12345,"eur").to_places(1).should == Commerce::Money.new(12345.1,"eur")
      Commerce::Money.new(12345.12345,"eur").to_places(2).should == Commerce::Money.new(12345.12,"eur")
      Commerce::Money.new(12345.12345,"eur").to_places(3).should == Commerce::Money.new(12345.123,"eur")
      Commerce::Money.new(12345.12345,"eur").to_places(4).should == Commerce::Money.new(12345.1234,"eur")
      Commerce::Money.new(12345.12345,"eur").to_places(5).should == Commerce::Money.new(12345.12345,"eur")
      Commerce::Money.new(12345.12345,"eur").to_places(6).should == Commerce::Money.new(12345.12345,"eur")
      Commerce::Money.new(12345.12345,"eur").to_places(7).should == Commerce::Money.new(12345.12345,"eur")
      Commerce::Money.new(12345.123456,"eur").to_places(7).should == Commerce::Money.new(12345.123456,"eur")
      Commerce::Money.new(12345.123456,"eur").to_places(5).should == Commerce::Money.new(12345.12346,"eur")
      Commerce::Money.new(12345.123455,"eur").to_places(5).should == Commerce::Money.new(12345.12346,"eur")
    end
    
    it "should round negative money values to given number of places" do
      Commerce::Money.new(-12345.12345,"eur").to_places(1).should == Commerce::Money.new(-12345.1,"eur")
      Commerce::Money.new(-12345.12345,"eur").to_places(2).should == Commerce::Money.new(-12345.12,"eur")
      Commerce::Money.new(-12345.12345,"eur").to_places(3).should == Commerce::Money.new(-12345.123,"eur")
      Commerce::Money.new(-12345.12345,"eur").to_places(4).should == Commerce::Money.new(-12345.1234,"eur")
      Commerce::Money.new(-12345.12345,"eur").to_places(5).should == Commerce::Money.new(-12345.12345,"eur")
      Commerce::Money.new(-12345.12345,"eur").to_places(6).should == Commerce::Money.new(-12345.12345,"eur")
      Commerce::Money.new(-12345.12345,"eur").to_places(7).should == Commerce::Money.new(-12345.12345,"eur")
      Commerce::Money.new(-12345.123456,"eur").to_places(7).should == Commerce::Money.new(-12345.123456,"eur")
      Commerce::Money.new(-12345.123456,"eur").to_places(5).should == Commerce::Money.new(-12345.12346,"eur")
      Commerce::Money.new(-12345.123455,"eur").to_places(5).should == Commerce::Money.new(-12345.12346,"eur")
    end
  end
  
 
end
