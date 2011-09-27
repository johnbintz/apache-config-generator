module Apache
  # Handle the creation of RewriteRules, RewriteConds, Redirects, and RedirectMatches
  module Rewrites
    # Enable the rewrite engine, optionally setting the logging level
    #
    #  enable_rewrite_engine :log_level => 1 #=>
    #    RewriteEngine on
    #    RewriteLogLevel 1
    def enable_rewrite_engine(options = {})
      blank_line!
      rewrite_engine! :on
      options.each do |option, value|
        case option
          when :log_level
            rewrite_log_level! value
        end
      end
      blank_line!
    end

    # Pass the block to RewriteManager.build
    def rewrites(*opt, &block)
      self + indent(RewriteManager.build(*opt, &block))
      self << ''
    end

    def rewrite(*opt, &block)
      raise "You probably want rewrites #{opt.quoteize * " "} do" if block
    end

    # Create a permanent Redirect
    #
    #  r301 '/here', '/there' #=> Redirect permanent "/here" "/there"
    def r301(*opt)
      if first = opt.first
        if !first.kind_of?(::String)
          raise "First parameter should be a String. Did you mean to wrap this in a rewrites block? #{first}"
        end
      end
      self << "Redirect permanent #{opt.quoteize * " "}"
    end
  end

  # Handle the creation of Rewritable things
  class RewriteManager
    class << self
      attr_accessor :rewrites

      # Reset the current list of rewrites
      def reset!
        @rewrites = []
        @any_tests = false
        @needs_tests = false
      end

      # Build rewritable things from the provided block
      def build(*opt, &block)
        reset!

        self.instance_eval(&block)

        name = block_name(opt.first)

        show_messages! name

        [ "# #{name}", @rewrites.collect(&:to_a) ].flatten
      end

      def block_name(first)
        first_rewrite = @rewrites.first

        first || (@rewrites.empty? ? 'unnamed block' : "#{first_rewrite.from} => #{first_rewrite.to}")
      end

      def show_messages!(name)
        blue = "rewrite".foreground(:blue)

        puts "  [#{blue}] no tests found for #{name}" if !@any_tests && !@rewrites.empty?
        puts "  [#{blue}] #{name} needs more tests" if @needs_tests
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
        @any_tests = true
        orig_from = from.dup
        @rewrites.each do |rewrite|
          if rewrite.match?(from, opts)
            from = rewrite.from_tester(from, opts)
            break if rewrite.stop_if_match?
          end
        end

        if from != to
          [ "#{orig_from} >> #{to} failed!", "Result: #{from}"
          ].each do |line|
            puts "  [#{"rewrite".foreground(:blue)}] #{line}"
          end
        end
      end

      def needs_tests
        @needs_tests = true
      end

      def cond_not_a_file(opts = {})
        cond_file_flag '!-f', opts
      end

      def cond_is_a_file(opts = {})
        cond_file_flag '-f', opts
      end

      def cond_not_a_directory(opts = {})
        cond_file_flag '!-d', opts
      end

      def cond_is_a_directory(opts = {})
        cond_file_flag '-d', opts
      end

      private
        def cond_file_flag(flag, opts)
          cond opts[:filename_only] ? "%{REQUEST_FILENAME}" : "%{DOCUMENT_ROOT}%{REQUEST_FILENAME}", flag
        end

    end
  end

  # Common methods for testing rewritable things that use regular expressions
  module RegularExpressionMatcher
    # Test this rewritable thing
    def test(from, opts = {})
      from.gsub(@from, @to.gsub(/\$([0-9])/) { |match| '\\' + $1 }).replace_placeholderize(opts)
    end

    def match?(from, opts = {})
      from.replace_placeholderize(opts)[@from]
    end
  end

  # A matchable thing to be extended
  class MatchableThing
    attr_reader :from, :to

    # The Apache directive tag for this thing
    def tag; raise 'Override this method'; end

    def initialize
      @from = nil
      @to = nil
    end

    def rule(from, to)
      raise "from must be a Regexp" if (!from.kind_of?(Regexp) && require_regexp?)

      @from = from
      @to = to
    end

    def to_s
      "#{tag} #{[@from, @to].quoteize.compact.flatten * " "}"
    end

    def to_a
      [ to_s ]
    end

    def stop_if_match?; false; end
    def forbidden?; false; end
    def require_regexp?; false; end

    def from_tester(from, opts)
      from = test(from, opts)
      from = :http_forbidden if (forbidden?)
      from
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
      @input_options = {}
    end

    # Define the rule, passing in additional options
    #
    # rule %r{^/here}, '/there', { :last => true, :preserve_query_string => true }
    #
    # Options for the options hash are:
    # * :last => true #=> [L]
    # * :forbidden => true #=> [F]
    # * :no_escape => true #=> [NE]
    # * :redirect => true #=> [R]
    # * :redirect => 302 #=> [R=302]
    # * :pass_through => true #=> [PT]
    # * :preserve_query_string => true #=> [QSA]
    # * :query_string_append => true #=> [QSA]
    # * :env => 'what' #=>  [E=what]
    def rule(from, to, options = {})
      super(from, to)

      @input_options = options

      @options = options.rewrite_rule_optionify.rewrite_option_listify
    end

    # Add a RewriteCondition to this RewriteRule
    def cond(from, to, *opts)
      rewrite_cond = RewriteCondition.new
      rewrite_cond.cond(from, to, *opts)

      @conditions << rewrite_cond
    end

    def initial_blank!
      @conditions.empty? ? nil : ''
    end

    def to_s
      "#{tag} #{[@from.source.quoteize, @to.quoteize, @options].compact.flatten * " "}"
    end

    def to_a
      [ initial_blank!, @conditions.collect(&:to_s), super ].flatten
    end

    # Test this RewriteRule, ensuring the RewriteConds also match
    def test(from, opts = {})
      ensure_opts!(opts)
      opts[:request_uri] = from
      result = from

      if match?(from, opts)
        if !(@to == '-')
          result = super(from, opts)
        end
      end

      result.replace_placeholderize(opts)
    end

    def ensure_opts!(opts)
      raise "Options must be a hash" if !opts
      raise "Options must be a hash" if !opts.kind_of? ::Hash
    end

    def match?(from, opts = {})
      ensure_opts!(opts)
      opts[:request_uri] = from

      @conditions.each do |cond|
        return false if !cond.test(from, opts)
      end

      super(from, opts)
    end

    def stop_if_match?
      @input_options[:last]
    end

    def forbidden?
      @input_options[:forbidden]
    end

    def require_regexp?; true; end
  end

  # A permanent RedirectMatch
  class RedirectMatchPermanent < MatchableThing
    include RegularExpressionMatcher

    # The Apache directive for this object.
    def tag; 'RedirectMatch permanent'; end

    # Define a RedirectMatch rule.
    def rule(from, to)
      super(from, to)

      raise "from must be a Regexp" if !from.kind_of?(Regexp)
    end

    # Convert this tag to a String.
    def to_s
      "#{tag} #{[@from.source, @to].quoteize.compact.flatten * " "}"
    end

    # Stop rewrite testing if this object matches.
    def stop_if_match; true; end
    def require_regexp?; true; end
  end

  # A RewriteCond
  class RewriteCondition < MatchableThing
    include RegularExpressionMatcher

    def tag; 'RewriteCond'; end

    # Define a RewriteCond
    #
    #  rule "%{REQUEST_FILENAME}", "^/here", :case_insensitive #=>
    #    RewriteCond "%{REQUEST_FILENAME}" "^/here" [NC]
    #
    # Additional parameters can include the following:
    # * :or #=> [OR]
    # * :case_insensitive #=> [NC]
    # * :no_vary #=> [NV]
    def rule(from, to, *opts)
      super(from, to)

      @options = opts.rewrite_cond_optionify.rewrite_option_listify
    end

    alias :cond :rule

    # Create a new RewriteCond
    def initialize
      super
      @options = nil
    end

    # Convert this tag to a String.
    def to_s
      "#{tag} #{[@from.quoteize, @to.quoteize, @options].compact.flatten * " "}"
    end

    def inverse_result?
      @to[0..0] == '!'
    end

    def actual_to
      to = @to
      to = to[1..-1] if inverse_result?
      to
    end

    # Test this RewriteCond
    def test(from, opts = {})
      super(from, opts)
      source = @from.replace_placeholderize(opts)

      to = actual_to

      case to
        when '-f'
          result = opts[:files].include?(source) if opts[:files]
        else
          result = source[Regexp.new(to)]
      end

      inverse_result? ? !result : result
    end
  end
end
