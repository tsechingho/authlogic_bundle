When /^I open the most recent email$/ do
  open_last_email
end

When /^I should have (an|\d+) emails at all$/ do |amount|
  amount = 1 if amount == "an"
  mailbox_for(current_email_address).size.should == amount.to_i
end
