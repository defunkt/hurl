module Views
  class Install < Layout
    def everything_installed?
      @everything_installed ||=
        xmllint_installed? && simplejson_installed? && pygments_installed?
    end

    def xmllint_installed?
      command? "which xmllint"
    end

    def simplejson_installed?
      command?("python -msimplejson.tool 0 2> /dev/null") ||
        $?.exitstatus == 255
    end

    def pygments_installed?
      command? "which #{Albino.bin}"
    end

    def xmllint_install_command
      if command? "brew"
        "brew install"
      elsif command? "apt-get"
        "apt-get install"
      elsif command? "emerge"
        "emerge"
      else
        "to get xmllint please install"
      end
    end

    def xmllint_install
      "#{xmllint_install_command} libxml2"
    end

    def simplejson_install
      "easy_install simplejson"
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
