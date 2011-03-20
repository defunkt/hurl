module Views
  class Install < Layout
    def everything_installed?
      @everything_installed ||= pygments_installed?
    end

    def pygments_installed?
      command? "which #{Albino.bin}"
    end

    def pygments_install
      "easy_install pygments"
    end

    def command?(command)
      system(command)
      $?.exitstatus == 0
    end
  end
end
