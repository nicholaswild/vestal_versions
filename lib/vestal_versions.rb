Dir[File.join(File.dirname(__FILE__), 'vestal_versions', '*.rb')].each{|f| require f }

module VestalVersions
  extend Configuration

  def self.extended(base)
    base.extend Versioned
  end

  def versioned(options = {}, &block)
    options.symbolize_keys!
    options.reverse_merge!(Configuration.options)
    options.reverse_merge!(
      :class_name => '::VestalVersions::Version',
      :dependent => :delete_all
    )

    class_inheritable_accessor :vestal_versions_options
    self.vestal_versions_options = options.dup

    self.vestal_versions_options[:only] = Array(options.delete(:only)).map(&:to_s).uniq if options[:only]
    self.vestal_versions_options[:except] = Array(options.delete(:except)).map(&:to_s).uniq if options[:except]

    self.vestal_versions_options[:if] = Array(options.delete(:if)).map(&:to_proc)
    self.vestal_versions_options[:unless] = Array(options.delete(:unless)).map(&:to_proc)

    options.merge!(
      :as => :versioned,
      :extend => Array(options[:extend]).unshift(Versions)
    )

    has_many :versions, options, &block

    include Changes
    include Creation
    include Users
    include Reversion
    include Reset
    include Conditions
    include Control
    include Tagging
    include Reload
  end
end

ActiveRecord::Base.extend(VestalVersions)
