require "spec_helper"

describe "currency" do
  describe "system has common currencies as default" do
    it( "should have us dollars" ){Commerce::Currency.find("USD").should_not == nil}
    it( "should have euros" ){Commerce::Currency.find("EUR").should_not == nil}
    it( "should have british pounds" ){Commerce::Currency.find("GBP").should_not == nil}
    it ("should have yen" ){Commerce::Currency.find("JPY").should_not == nil}
    it ("should have yuan" ){Commerce::Currency.find("CNY").should_not == nil}
  end
  
  describe "currencies have decimal places" do
    it ("should have 2 decimal places for dollars"){Commerce::Currency.find("USD").places.should == 2}
    it ("should have 2 decimal places for euros"){Commerce::Currency.find("EUR").places.should == 2}
    it ("should have 0 decimal places for yen"){Commerce::Currency.find("JPY").places.should == 0}
    it ("should have 0 decimal places for yuan"){Commerce::Currency.find("CNY").places.should == 0}
  end
  
  describe "currencies can be lower or uppercase" do
    it( "should find USD" ){Commerce::Currency.find("USD").should_not == nil}
    it( "should find usd" ){Commerce::Currency.find("usd").should_not == nil}
    it( "should find EUR" ){Commerce::Currency.find("EUR").should_not == nil}
    it( "should find eur" ){Commerce::Currency.find("eur").should_not == nil}
    it( "should find GBP" ){Commerce::Currency.find("GBP").should_not == nil}
    it( "should find gbp" ){Commerce::Currency.find("gbp").should_not == nil}
  end
  
  describe "id" do
    it "should return the value of the code" do
      Commerce::Currency.find("USD").id.should == "USD"
      Commerce::Currency.find(:eur).id.should == "EUR"
    end
  end
  
end