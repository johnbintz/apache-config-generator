class Hash
  def to_sym_keys
    Hash[self.collect { |key, value|
      value = value.to_sym_keys if value.kind_of?(Hash)
      [ key.to_sym, value ]
    }]
  end
end