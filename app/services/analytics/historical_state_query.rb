module Analytics
  # Service object to determine which records from a collection existed and were not
  # destroyed at a specific point in time, based on their `created_at` timestamps
  # and their associated `Journal` entries.
  class HistoricalStateQuery
    # Finds records that were active at a specific date.
    #
    # @param relation [ActiveRecord::Relation] The initial relation to query (e.g., ContactEmployment.all).
    # @param date [Date] The date for which to determine the state.
    # @return [ActiveRecord::Relation] A relation containing the records that were active on the given date.
    def self.records_at(relation, date)
      new(relation, date).records_at_date
    end

    def initialize(relation, date)
      @relation = relation
      @date = date
      @model_class = relation.klass
    end

    def records_at_date
      # Start with records created on or before the target date.
      created_before_date_ids = @relation.where('created_at <= ?', @date.end_of_day).pluck(:id)

      # Find IDs of records that were destroyed on or before the target date.
      destroyed_before_date_ids = Journal.where(journalized_type: @model_class.name, journalized_id: created_before_date_ids)
                                         .where(notes: 'Destroyed')
                                         .where('created_on <= ?', @date.end_of_day)
                                         .pluck(:journalized_id)

      # The records that existed are those that were created but not destroyed.
      active_ids = created_before_date_ids - destroyed_before_date_ids

      @relation.where(id: active_ids)
    end
  end
end