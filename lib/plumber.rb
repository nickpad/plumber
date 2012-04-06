require "plumber/version"
require "plumber/context"

require "active_record"

# Provides functionality for creating and updating ActiveRecord model objects. Requires Rails 3+.
class Plumber
  # Create a new instance which will act on the given model and log to the given logger.
  def initialize(model, logger)
    @model = model
    @logger = logger
  end

  def import
    context = Plumber::Context.new(@model.scoped)

    yield context

    operation = if context.record.new_record?
                  "Create"
                else
                  "Update"
                end

    changed = context.record.changed

    begin
      ActiveRecord::Base.transaction do
        if context.record.save!
          if changed
            @logger.info("#{operation} #{context.record.class} #{context.record.id}.")
          else
            @logger.debug("#{context.record.class} #{context.record.id} not changed.")
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      prefix = "#{e.record.class} #{e.record.id}".strip

      @logger.warn("#{prefix}: #{operation} failed - #{e.record.errors.size} validation errors.")

      context.record.errors.full_messages.each do |message|
        @logger.warn("#{prefix}: #{message}")
      end
    end

    context.record
  end
end
