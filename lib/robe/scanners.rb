module Robe
  class Scanner
    attr_accessor :check_private
    attr_reader :candidates

    def initialize(sym, check_private)
      @candidates = []
      @sym = sym
      @check_private = check_private
    end

    def scan(modules, check_instance, check_module)
      modules.each do |m|
        if check_module
          sc = m.__singleton_class__
          scan_methods(sc, :instance_methods)
          scan_methods(sc, :private_instance_methods) if check_private
        end
        if check_instance
          scan_methods(m, :instance_methods)
          scan_methods(m, :private_instance_methods) if check_private
        end
      end
    end
  end

  class ModuleScanner < Scanner
    def scan_methods(mod, coll)
      if mod.__send__(coll, false).include?(@sym)
        begin
          candidates << mod.instance_method(@sym)
        rescue NameError
        end
      end
    end
  end

  class MethodScanner < Scanner
    def initialize(*args)
      super
      @re = /^#{Regexp.escape(@sym || "")}/
    end

    def scan_methods(mod, coll)
      mod.__send__(coll, false).grep(@re) do |sym|
        begin
          candidates << mod.instance_method(sym)
        rescue NameError
        end
      end
    end
  end
end
