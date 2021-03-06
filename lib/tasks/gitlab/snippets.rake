# frozen_string_literal: true

namespace :gitlab do
  namespace :snippets do
    DEFAULT_LIMIT = 100

    # @example
    #   bundle exec rake gitlab:snippets:migrate SNIPPET_IDS=1,2,3,4
    #   bundle exec rake gitlab:snippets:migrate SNIPPET_IDS=1,2,3,4 LIMIT=50
    desc 'GitLab | Migrate specific snippets to git'
    task :migrate, [:ids] => :environment do |_, args|
      unless ENV['SNIPPET_IDS'].presence
        raise "Please supply the list of ids through the SNIPPET_IDS env var"
      end

      raise "Invalid limit value" if limit.zero?

      if migration_running?
        raise "There are already snippet migrations running. Please wait until they are finished."
      end

      ids = parse_snippet_ids!

      puts "Starting the migration..."
      Gitlab::BackgroundMigration::BackfillSnippetRepositories.new.perform_by_ids(ids)

      list_non_migrated = non_migrated_snippets.where(id: ids)

      if list_non_migrated.exists?
        puts "The following snippets couldn't be migrated:"
        puts list_non_migrated.pluck(:id).join(',')
      else
        puts "All snippets were migrated successfully"
      end
    end

    def parse_snippet_ids!
      ids = ENV['SNIPPET_IDS'].delete(' ').split(',').map do |id|
        id.to_i.tap do |value|
          raise "Invalid id provided" if value.zero?
        end
      end

      if ids.size > limit
        raise "The number of ids provided is higher than #{limit}. You can update this limit by using the env var `LIMIT`"
      end

      ids
    end

    # @example
    #   bundle exec rake gitlab:snippets:migration_status
    desc 'GitLab | Show whether there are snippet background migrations running'
    task migration_status: :environment do
      if migration_running?
        puts "There are snippet migrations running"
      else
        puts "There are no snippet migrations running"
      end
    end

    def migration_running?
      Sidekiq::ScheduledSet.new.any? { |r| r.klass == 'BackgroundMigrationWorker' && r.args[0] == 'BackfillSnippetRepositories' }
    end

    # @example
    #   bundle exec rake gitlab:snippets:list_non_migrated
    #   bundle exec rake gitlab:snippets:list_non_migrated LIMIT=50
    desc 'GitLab | Show non migrated snippets'
    task list_non_migrated: :environment do
      raise "Invalid limit value" if limit.zero?

      non_migrated_count = non_migrated_snippets.count
      if non_migrated_count.zero?
        puts "All snippets have been successfully migrated"
      else
        puts "There are #{non_migrated_count} snippets that haven't been migrated. Showing a batch of ids of those snippets:\n"
        puts non_migrated_snippets.limit(limit).pluck(:id).join(',')
      end
    end

    def non_migrated_snippets
      @non_migrated_snippets ||= Snippet.select(:id).where.not(id: SnippetRepository.select(:snippet_id))
    end

    # There are problems with the specs if we memoize this value
    def limit
      ENV['LIMIT'] ? ENV['LIMIT'].to_i : DEFAULT_LIMIT
    end
  end
end
