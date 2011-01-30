require "../../lib/fidius/design_patterns/observer"

class BlinkingLight < Observable
  
  def blink
    notify_all("blink blink !")
  end

end

class LightObserver

  def notify(msg)
    puts msg
  end

end

light = BlinkingLight.new
human_eye = LightObserver.new
light.register(human_eye)
light.blink
