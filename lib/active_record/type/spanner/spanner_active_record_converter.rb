# Copyright 2021 Google LLC
#
# Use of this source code is governed by an MIT-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/MIT.

# frozen_string_literal: true

module ActiveRecord
  module Type

    unless defined? Json
      class Json < ActiveModel::Type::Value
        include ActiveModel::Type::Helpers::Mutable

        def type
          :json
        end

        def deserialize(value)
          return value unless value.is_a?(::String)
          ActiveSupport::JSON.decode(value) rescue nil
        end

        def serialize(value)
          ActiveSupport::JSON.encode(value) unless value.nil?
        end

        def changed_in_place?(raw_old_value, new_value)
          deserialize(raw_old_value) != new_value
        end

        def accessor
          ActiveRecord::Store::StringKeyedHashAccessor
        end
      end
    end

    module Spanner
      class SpannerActiveRecordConverter
        ##
        # Converts an ActiveModel::Type to a Spanner type code.
        def self.convert_active_model_type_to_spanner type # rubocop:disable Metrics/CyclomaticComplexity
          case type
          when NilClass then nil
          when ActiveModel::Type::Integer, ActiveModel::Type::BigInteger then :INT64
          when ActiveModel::Type::Boolean then :BOOL
          when ActiveModel::Type::String, ActiveModel::Type::ImmutableString then :STRING
          when ActiveModel::Type::Binary, ActiveRecord::Type::Spanner::Bytes then :BYTES
          when ActiveModel::Type::Float then :FLOAT64
          when ActiveModel::Type::Decimal then :NUMERIC
          when ActiveModel::Type::DateTime, ActiveModel::Type::Time, ActiveRecord::Type::Spanner::Time then :TIMESTAMP
          when ActiveModel::Type::Date then :DATE
          when ActiveRecord::Type::Json then :JSON
          when ActiveRecord::Type::Spanner::Array then [convert_active_model_type_to_spanner(type.element_type)]
          end
        end
      end
    end
  end
end
