module GettextI18nRails
  class Railtie < ::Rails::Railtie
    config.gettext_i18n_rails = ActiveSupport::OrderedOptions.new
    config.gettext_i18n_rails.msgmerge = nil
    config.gettext_i18n_rails.xgettext = nil
    config.gettext_i18n_rails.use_for_active_record_attributes = true

    rake_tasks do
      begin
        gem "gettext", ">= 3.0.2"
        require 'gettext_i18n_rails/tasks'
      rescue Gem::LoadError
        # no gettext available, no tasks for you!
      end
    end

    initializer "gettext_i18n_rails.callbacks" do |app|
      repo = FastGettext.translation_repositories[FastGettext.text_domain]
      if repo.is_a? FastGettext::TranslationRepository::Po
        reloader = ActiveSupport::FileUpdateChecker.new([], FastGettext.locale_path => :po) do
          FastGettext.reload!
        end
        app.reloaders << reloader
        ActionDispatch::Reloader.to_prepare do
          reloader.execute
        end
      end
    end

    config.after_initialize do |app|
      if app.config.gettext_i18n_rails.use_for_active_record_attributes
        ActiveSupport.on_load :active_record do
          require 'gettext_i18n_rails/active_model'
        end
      end
    end
  end
end
