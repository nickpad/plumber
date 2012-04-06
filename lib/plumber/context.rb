class Plumber
  class Context
    MAX_ASSOCIATION_COUNT = 50

    attr_reader :scope, :conditions, :mapping, :associations

    def initialize(scope, parent = nil)
      @scope = scope
      @parent = parent
      @conditions = {}
      @mapping = {}
      @associations = []
    end

    def conditions(hash)
      @conditions = hash
    end

    def mapping(hash)
      @mapping = hash
    end

    def association(name)
      scope = record.send(name)
      context = self.class.new(scope, self)

      yield context

      @associations << context

      # Return the record defined in the yielded context:
      context.record
    end

    def record
      if @record.nil?
        @record = if @parent.nil?
                    # If this is a top-level context, use a database query to look up an
                    # existing record that matches the conditions supplied.
                    @scope.where(@conditions).first
                  else
                    # Because ActiveRecord (currently) doesn't have an "Identity Map" feature,
                    # unfortunately for associated records we can't run a DB query to find
                    # existing records.
                    #
                    # Instead we load all records in the scope and search for one matching
                    # the conditions supplied. This is why we check the scope size and raise
                    # an exception if it's too large - for situations where there are
                    # potentially large numbers of associated records, a separate Importer
                    # instance should be defined for handling those records.
                    if @scope.count > MAX_ASSOCIATION_COUNT
                      message = "%s scope contains too many records (%s)" % [
                          @scope.new.class, @scope.count
                      ]

                      raise RuntimeError, message
                    end

                    @scope.detect do |record|
                      @conditions.all? { |k, v| record.send(k) == v }
                    end
                  end

        # If an existing record hasn't been found in the scope, build a new one:
        @record ||= @scope.build

        @conditions.merge(@mapping).each do |key, value|
          @record.send("#{key}=", value)
        end
      end

      @record
    end
  end
end
