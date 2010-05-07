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

        @rewrites.collect(&:to_a).flatten
      end

      def commit!
        @rewrites << @rewrite
        @rewrite = nil
      end

      def ensure_rewrite!
        @rewrite = RewriteRule.new if !@rewrite
      end

      def rewrite(*opts)
        ensure_rewrite!
        @rewrite.rule(*opts)
        commit!
      end

      def cond(*opts)
        ensure_rewrite!
        @rewrite.cond(*opts)
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
    include Apache::Quoteize

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
      @options = opts.first
    end

    def cond(from, to, *opts)
      rewrite_cond = RewriteCondition.new
      rewrite_cond.cond(from, to, *opts)

      @conditions << rewrite_cond
    end

    def test(from, opts)
      from = from.gsub(@from, @to.gsub(/\$([0-9])/) { |m| '\\' + $1 })
      opts.each do |opt, value|
        from = from.gsub('%{' + opt.to_s.upcase + '}', value)
      end
      from
    end

    def to_a
      output = @conditions.collect(&:to_s)

      options = @options.collect do |key, value|
        case key
          when :last
            'L'
          when :preserve_query_string
            'QSA'
        end
      end

      if !options.empty?
        options = "[#{options * ','}]"
      else
        options = nil
      end

      output << "#{tag} #{[quoteize(@from.source), quoteize(@to), options].compact.flatten * " "}"

      output
    end
  end

  class RewriteRule < MatchableThing
    def tag; 'RewriteRule'; end
  end

  class RedirectMatchPermanent < MatchableThing
    def tag; 'RedirectMatch permanent'; end
  end

  class RewriteCondition < MatchableThing
    def tag; 'RewriteCond'; end
    alias :cond :rule

    def to_s
      "#{tag} #{[quoteize(@from), quoteize(@to), @options].flatten * " "}"
    end
  end
end
