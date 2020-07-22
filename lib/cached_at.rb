require "cached_at/version"

module CachedAt
  def self.included(klass)
    klass.instance_eval do
      before_save :_set_cached_at
      klass.extend ClassMethods
    end
  end

  def cache_key
    case
    when new_record?
      "#{self.class.model_name.cache_key}/new"
    when timestamp = self[:cached_at]
      timestamp = timestamp.utc.to_s(:number)
      "#{self.class.model_name.cache_key}/#{id}-#{timestamp}"
    else
      "#{self.class.model_name.cache_key}/#{id}"
    end
  end

  def touch(name = nil)
    update_column :cached_at, Time.current
  end

  module ClassMethods
    def cache_key
      "#{model_name}-#{maximum(:cached_at).to_i}"
    end
  end

  private
  def _set_cached_at
    self.cached_at = Time.current if new_record? || self.changed?
  end
end
