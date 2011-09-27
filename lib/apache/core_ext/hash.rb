class Hash
  def to_sym_keys
    Hash[self.collect { |key, value|
      value = value.to_sym_keys if value.kind_of?(Hash)
      [ key.to_sym, value ]
    }]
  end

  REWRITE_RULE_CONDITIONS = {
    :last => 'L',
    :forbidden => 'F',
    :no_escape => 'NE',
    :redirect => lambda { |val| val == true ? 'R' : "R=#{val}" },
    :pass_through => 'PT',
    :preserve_query_string => 'QSA',
    :query_string_append => 'QSA',
    :proxy => 'P',
    :env => lambda { |val| "E=#{val}" }
  }

  def rewrite_rule_optionify
    self.collect do |key, value|
      what = REWRITE_RULE_CONDITIONS[key]
      what = what.call(value) if what.kind_of? Proc
      what
    end.compact.sort
  end
end
