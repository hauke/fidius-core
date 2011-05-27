module FIDIUS
  class ActionRecommendation

    def initialize
      create()
      @current_state = @emission.index("start")
    end

    def next
      possible_next = []
      i = 0
      @transition[@current_state].each do |x|
        possible_next << @emission[i] if x == 1 
        i = i + 1
      end
      possible_next
    end

    def take_step action
      @current_state = @emission.index(action)
    end

    private

    def create
      @emission = ["start", "on host", "scan", "passive scan", "choose target", "choose port","exploit", "look interfaces"]
      @transition = [
                     [0, 0, 1, 1, 0, 0, 0, 0], # s0 START
                     [1, 0, 0, 0, 0, 0, 0, 1], # s1 ON HOST 
                     [0, 0, 0, 0, 1, 0, 0, 0], # s2 SCAN
                     [0, 0, 0, 0, 1, 0, 0, 0], # s3 PASSIVE SCAN
                     [0, 0, 0, 0, 0, 1, 0, 0], # s4 CHOOSE TARGET
                     [0, 0, 0, 0, 0, 0, 1, 0], # s5 CHOOSE PORT
                     [0, 1, 0, 0, 1, 1, 0, 0], # s6 EXPLOIT
                     [1, 0, 0, 0, 0, 0, 0, 0], # s7 LOOK INTERFACES
                    ]
    end

  end
end
