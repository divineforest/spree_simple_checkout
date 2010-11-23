# customize the checkout state machine
Order.state_machines[:state] = StateMachine::Machine.new(Order, :initial => 'cart', :use_transactions => false) do
  event :next do
    transition :from => 'cart', :to => 'address'
    transition :from => 'address', :to => 'complete'
  end

  event :cancel do
    transition :to => 'canceled', :if => :allow_cancel?
  end
  event :return do
    transition :to => 'returned', :from => 'awaiting_return'
  end
  event :resume do
    transition :to => 'resumed', :from => 'canceled', :if => :allow_resume?
  end
  event :authorize_return do
    transition :to => 'awaiting_return'
  end

  after_transition :to => 'complete', :do => :finalize!
  after_transition :to => 'canceled', :do => :after_cancel
end

Order.class_eval do
  def payment?
    false
  end
end
