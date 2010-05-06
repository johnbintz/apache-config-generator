module Apache
  module Rewrites
    def enable_rewrite_engine(options)
      self << ''
      rewrite_engine! :on
      options.each do |option, value|
        case option
          when :log_level
            rewrite_log_level! value
        end
      end
      self << ''
    end

    def rewrites(&block)
      self + indent(RewriteManager.build(&block))
      self << ''
    end

    def r301(*opt)
      self << "Redirect permanent #{quoteize(*opt) * " "}"
    end
  end

  class RewriteManager
    class << self
      attr_accessor :rewrites

      def build(&block)
        @rewrites = []

        self.instance_eval(&block)

        @rewrites
      end

      def rewrite(*opts)
        @rewrite = RewriteRule.new
        @rewrite.rule(*opts)

        @rewrites << @rewrite
      end

      def r301(*opts)
        redirect = RedirectMatchPermanent.new
        redirect.rule(*opts)

        @rewrites << redirect
      end

      def rewrite_test(from, to, opts = {})
        orig_from = from.dup
        @rewrites.each do |r|
          from = r.test(from, opts)
        end

        if from != to
          puts "[warn] #{orig_from} >> #{to} failed!"
          puts "[warn] Result: #{from}"
        end
      end
    end
  end

  class MatchableThing
    def tag; raise 'Override this method'; end

    def initialize
      @from = nil
      @to = nil
      @options = nil
      @conditions = []
    end

    def rule(from, to, *opts)
      @from = from
      @to = to
      @options = opts
    end

    def test(from, opts)
      from = from.gsub(@from, @to.gsub(/\$([0-9])/) { |m| '\\' + $1 })
      opts.each do |opt, value|
        from = from.gsub('%{' + opt.to_s.upcase + '}', value)
      end
      from
    end

    def to_s
      output = []

      @conditions.each do |condition|

      end

      output << "#{tag} #{[@from.source, @to, @options].flatten * " "}"

      output * "\n"
    end
end

  class RewriteRule < MatchableThing
    def tag; 'RewriteRule'; end
  end

  class RedirectMatchPermanent < MatchableThing
    def tag; 'RedirectMatch permanent'; end
  end
end
