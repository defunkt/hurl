module Views
  class Install < Layout
    def everything_installed?
      @everything_installed ||=
        xmllint_installed? && simplejson_installed? && pygments_installed?
    end

    def xmllint_installed?
      system("which xmllint")
      $?.exitstatus == 0
    end

    def simplejson_installed?
      system("python -msimplejson.tool 0 2> /dev/null")
      $?.exitstatus != 1
    end

    def pygments_installed?
      system("which #{Albino.bin}")
      $?.exitstatus == 0
    end

    def xmllint_install
      "brew install libxml2"
    end

    def simplejson_install
      "easy_install simplejson"
    end

    def pygments_install
      "easy_install pygments"
    end
  end
end
