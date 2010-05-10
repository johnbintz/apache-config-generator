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

      def reset!
        @rewrites = []
      end

      def build(&block)
        reset!

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

      alias :rule :rewrite

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

  module RegularExpressionMatcher
    def test(from, opts = {})
      from = from.gsub(@from, @to.gsub(/\$([0-9])/) { |m| '\\' + $1 })
      replace_placeholders(from, opts)
    end

    def replace_placeholders(s, opts)
      opts.each do |opt, value|
        case value
          when String
            s = s.gsub('%{' + opt.to_s.upcase + '}', value)
        end
      end
      s
    end
  end

  class MatchableThing
    include Apache::Quoteize

    def tag; raise 'Override this method'; end

    def initialize
      @from = nil
      @to = nil
    end

    def rule(from, to)
      @from = from
      @to = to
    end

    def to_s
      "#{tag} #{[quoteize(@from), quoteize(@to)].compact.flatten * " "}"
    end

    def to_a
      [ to_s ]
    end
  end

  class RewriteRule < MatchableThing
    include RegularExpressionMatcher

    def tag; 'RewriteRule'; end

    def initialize
      super
      @conditions = []
      @options = nil
    end

    def rule(from, to,options = {})
      super(from, to)

      raise "from must be a Regexp" if !from.kind_of?(Regexp)

      options = options.collect do |key, value|
        case key
          when :last
            'L'
          when :preserve_query_string
            'QSA'
        end
      end.sort

      @options = !options.empty? ? "[#{options * ','}]" : nil
    end

    def cond(from, to, *opts)
      rewrite_cond = RewriteCondition.new
      rewrite_cond.cond(from, to, *opts)

      @conditions << rewrite_cond
    end

    def to_s
      "#{tag} #{[quoteize(@from.source), quoteize(@to), @options].compact.flatten * " "}"
    end

    def to_a
      output = @conditions.collect(&:to_s)

      output += super

      output
    end

    def test(from, opts = {})
      ok = true
      @conditions.each do |c|
        ok = false if !c.test(from, opts)
      end

      if ok
        super(from, opts)
      else
        replace_placeholders(from, opts)
      end
    end
  end

  class RedirectMatchPermanent < MatchableThing
    include RegularExpressionMatcher

    def tag; 'RedirectMatch permanent'; end

    def to_s
      "#{tag} #{[quoteize(@from.source), quoteize(@to)].compact.flatten * " "}"
    end
  end

  class RewriteCondition < MatchableThing
    include RegularExpressionMatcher

    def tag; 'RewriteCond'; end

    def rule(from, to, *opts)
      super(from, to)

      options = opts.collect do |opt|
        case opt
          when :or
            'OR'
          when :case_insensitive
            'NC'
          when :no_vary
            'NV'
        end
      end

      @options = (!options.empty?) ? "[#{options * ','}]" : nil
    end

    alias :cond :rule

    def initialize
      super
      @options = nil
    end

    def to_s
      "#{tag} #{[quoteize(@from), quoteize(@to), @options].compact.flatten * " "}"
    end

    def test(from, opts = {})
      super(from, opts)
      source = replace_placeholders(@from, opts)

      result = false
      case @to[0..0]
        when '!'
          result = !source[Regexp.new(@to[1..-1])]
        when '-'
          case @to
            when '-f'
              result = opts[:files].include? source if opts[:files]
          end
        else
          result = source[Regexp.new(@to)]
      end

      result
    end
  end
end
