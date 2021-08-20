# frozen_string_literal: true

Rails.application.configure do
  config.lograge.custom_options = lambda do |event|
    ElasticAPM.log_ids do |transaction_id, span_id, trace_id|
      { :'transaction.id' => transaction_id,
        :'span.id' => span_id,
        :'trace.id' => trace_id }
    end
  end
end
