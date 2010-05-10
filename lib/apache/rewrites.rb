module Apache
  # Handle the creation of RewriteRules, RewriteConds, Redirects, and RedirectMatches
  module Rewrites
    # Enable the rewrite engine, optionally setting the logging level
    #
    #  enable_rewrite_engine :log_level => 1 #=>
    #    RewriteEngine on
    #    RewriteLogLevel 1
    def enable_rewrite_engine(options = {})
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

    # Pass the block to RewriteManager.build
    def rewrites(&block)
      self + indent(RewriteManager.build(&block))
      self << ''
    end

    # Create a permanent Redirect
    #
    #  r301 '/here', '/there' #=> Redirect permanent "/here" "/there"
    def r301(*opt)
      self << "Redirect permanent #{quoteize(*opt) * " "}"
    end
  end

  # Handle the creation of Rewritable things
  class RewriteManager
    class << self
      attr_accessor :rewrites

      # Reset the current list of rewrites
      def reset!
        @rewrites = []
      end

      # Build rewritable things from the provided block
      def build(&block)
        reset!

        self.instance_eval(&block)

        @rewrites.collect(&:to_a).flatten
      end

      # Commit the latest rewritable thing to the list of rewrites
      def commit!
        @rewrites << @rewrite
        @rewrite = nil
      end

      # Ensure that there's a RewriteRule to be worked with
      def ensure_rewrite!
        @rewrite = RewriteRule.new if !@rewrite
      end

      # Create a RewriteRule with the given options
      #
      #  rewrite %r{/here(.*)}, '/there$1', :last => true #=>
      #    RewriteRule "/here(.*)" "/there$1" [L]
      def rewrite(*opts)
        ensure_rewrite!
        @rewrite.rule(*opts)
        commit!
      end

      alias :rule :rewrite

      # Create a RewriteCond with the given options
      #
      #  cond "%{REQUEST_FILENAME}", "^/here" #=>
      #    RewriteCond "%{REQUEST_FILENAME}", "^/here"
      def cond(*opts)
        ensure_rewrite!
        @rewrite.cond(*opts)
      end

      # Create a permanent RedirectMatch
      #
      #  r301 %r{/here(.*)}, "/there$1" #=>
      #    RedirectMatch permanent "/here(.*)" "/there$1"
      def r301(*opts)
        redirect = RedirectMatchPermanent.new
        redirect.rule(*opts)

        @rewrites << redirect
      end

      # Test the rewritable things defined in this block
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

  # Common methods for testing rewritable things that use regular expressions
  module RegularExpressionMatcher
    # Test this rewritable thing
    def test(from, opts = {})
      from = from.gsub(@from, @to.gsub(/\$([0-9])/) { |m| '\\' + $1 })
      replace_placeholders(from, opts)
    end

    # Replace the placeholders in this rewritable thing
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

  # A matchable thing to be extended
  class MatchableThing
    include Apache::Quoteize

    # The Apache directive tag for this thing
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

  # A RewriteRule definition
  class RewriteRule < MatchableThing
    include RegularExpressionMatcher

    def tag; 'RewriteRule'; end

    def initialize
      super
      @conditions = []
      @options = nil
    end

    # Define the rule, passing in additional options
    #
    # rule %r{^/here}, '/there', { :last => true, :preserve_query_string => true }
    def rule(from, to,options = {})
      super(from, to)

      raise "from must be a Regexp" if !from.kind_of?(Regexp)

      options = options.collect do |key, value|
        case key
          when :last
            'L'
          when :pass_through
            'PT'
          when :preserve_query_string
            'QSA'
        end
      end.sort

      @options = !options.empty? ? "[#{options * ','}]" : nil
    end

    # Add a RewriteCondition to this RewriteRule
    def cond(from, to, *opts)
      rewrite_cond = RewriteCondition.new
      rewrite_cond.cond(from, to, *opts)

      @conditions << rewrite_cond
    end

    def to_s
      "#{tag} #{[quoteize(@from.source), quoteize(@to), @options].compact.flatten * " "}"
    end

    def to_a
      [ @conditions.collect(&:to_s), super ].flatten
    end

    # Test this RewriteRule, ensuring the RewriteConds also match
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

  # A permanent RedirectMatch
  class RedirectMatchPermanent < MatchableThing
    include RegularExpressionMatcher

    def tag; 'RedirectMatch permanent'; end

    def rule(from, to)
      super(from, to)

      raise "from must be a Regexp" if !from.kind_of?(Regexp)
    end

    def to_s
      "#{tag} #{[quoteize(@from.source), quoteize(@to)].compact.flatten * " "}"
    end
  end

  # A RewriteCond
  class RewriteCondition < MatchableThing
    include RegularExpressionMatcher

    def tag; 'RewriteCond'; end

    # Define a RewriteCond
    #
    #  rule "%{REQUEST_FILENAME}", "^/here", :case_insensitive #=>
    #    RewriteCond "%{REQUEST_FILENAME}" "^/here" [NC]
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

    # Test this RewriteCond
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
