module I18n
  # Implemented to support method call on translation keys
  INTERPOLATION_WITH_METHOD_PATTERN = Regexp.union(
    /%%/,
    /%\{(\w+)\}/,                               # matches placeholders like "%{foo}"
    /%<(\w+)>(.*?\d*\.?\d*[bBdiouxXeEfgGcps])/, # matches placeholders like "%<foo>.d"
    /%\{(\w+)\.(\w+)\}/,                          # matches placeholders like "%{foo.upcase}"
  )

  class << self
    def interpolate_hash(string, values)
      string.gsub(INTERPOLATION_WITH_METHOD_PATTERN) do |match|
        if match == '%%'
          '%'
        else
          key = ($1 || $2 || $4).to_sym
          value = values.key?(key) ? values[key] : raise(MissingInterpolationArgument.new(values, string))
          value = value.call(values) if value.respond_to?(:call)
          $3 ? sprintf("%#{$3}", value) : ( $5 ? value.send($5) : value) 
        end
      end
    end
  end
end