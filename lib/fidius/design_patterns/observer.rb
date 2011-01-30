class Observable
  
  def initialize
    @observers = []
  end

  def register(observer)
    @observers << observer
  end

  protected
  def notify_all(msg)
    @observers.each do |observer|
      observer.notify(msg)
    end
  end

end
