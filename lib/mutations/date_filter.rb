module Mutations
  class DateFilter < InputFilter
    @default_options = {
      :nils => false,       # true allows an explicit nil to be valid. Overrides any other options
      :format => nil,       # If nil, Date.parse will be used for coercsion. If something like "%Y-%m-%d", Date.strptime is used
      :after => nil,        # A date object, representing the minimum date allowed, inclusive
      :before => nil        # A date object, representing the maximum date allowed, inclusive
    }

    def filter(data)
      # Handle nil case
      if data.nil?
        return [nil, nil] if options[:nils]
        return [nil, :nils]
      end

      begin
        if !data.is_a?(Date)
          if options[:format]
            actual_date = Date.strptime(data, options[:format])
          else
            actual_date = Date.parse(data)
          end
        else
          actual_date = data
        end
      rescue ArgumentError
        return [nil, :date]
      end

      # Ok, its a valid date, check if it falls within the range
      if options[:after]
        if actual_date <= options[:after]
          return [nil, :after]
        end
      end

      if options[:before]
        if actual_date >= options[:before]
          return [nil, :before]
        end
      end

      # We win, it's valid!
      [actual_date, nil]
    end
  end
end
