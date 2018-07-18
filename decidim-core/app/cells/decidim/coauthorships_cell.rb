# frozen_string_literal: true

module Decidim
  # This cell renders a collapsible list of a model's coauthors.
  #
  # Available sizes:
  #  - `:small` => collapses after 3 elements.
  #  - `:default` => collapses after 7 elements. If not specified, this one is
  #    used.
  #
  # Extra params:
  # - `extra_small` => boolean: when this cell is included in small places this
  #     option adds extra css ("author-data--small") to make the box smaller.
  #
  # Example:
  #
  #    cell("decidim/coauthorships", @proposal)
  class CoauthorshipsCell < Decidim::ViewModel
    include Decidim::ApplicationHelper

    def show
      if authorable? || official?
        cell "decidim/author", presenter_for_author(model), options: extra_classes, has_actions: has_actions?, from: model
      else
        cell(
          "decidim/collapsible_authors",
          presenters_for_identities(model),
          cell_name: "decidim/author",
          cell_options: extra_classes,
          size: 3,
          from: model,
          has_actions: has_actions?
        )
      end
    end

    private

    def official?
      model.respond_to?(:official?) && model.official?
    end

    def presenters_for_identities(coauthorable)
      coauthorable.identities.map { |identity| present(identity) }
    end

    def presenter_for_author(authorable)
      if official?
        "#{model.class.parent}::OfficialAuthorPresenter".constantize.new
      elsif authorable.user_group
        Decidim::UserGroupPresenter.new(authorable.user_group)
      else
        Decidim::UserPresenter.new(authorable.author)
      end
    end

    def authorable?
      model.is_a?(Decidim::Authorable)
    end

    def has_actions?
      options[:has_actions] == true
    end

    def extra_classes
      if options[:extra_small]
        { extra_classes: ["author-data--small"] }
      else
        {}
      end
    end
  end
end
