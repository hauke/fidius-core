require 'test_fidius'

class BlinkingLight < Observable
  def blink
    notify_all("blink blink !")
    true
  end
end

class LightObserver
  def notify(msg)
    puts msg
  end
end

class ObserverTest < FIDIUS::Test
  def test_observer
    light = BlinkingLight.new
    human_eye = LightObserver.new
    light.register(human_eye)
    assert light.blink
  end
end

