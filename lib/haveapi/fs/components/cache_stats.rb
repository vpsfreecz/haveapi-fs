module HaveAPI::Fs::Components
  class CacheStats < File
    def read
      c = context.cache

      {
          size: c.size,
          hits: c.hits,
          misses: c.misses,
          invalid: c.invalid,
          drops: c.drops,
          hitratio: (c.hits.to_f / (c.hits + c.misses + c.invalid) * 100).round(2),
          sweeps: c.runs,
          next_sweep: c.next_time.iso8601,
      }.map { |k, v| sprintf('%-15s %s', "#{k}:", v) }.join("\n") + "\n"
    end
  end
end
