# frozen_string_literal: true

module Decidim
  module Proposals
    #
    # Decorator for proposals
    #
    class ProposalPresenter < SimpleDelegator
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper

      def author
        @author ||= if official?
                      Decidim::Proposals::OfficialAuthorPresenter.new
                    else
                      coauthorship = coauthorships.first
                      if coauthorship.user_group
                        Decidim::UserGroupPresenter.new(coauthorship.user_group)
                      else
                        Decidim::UserPresenter.new(coauthorship.author)
                      end
                    end
      end

      def proposal_path
        proposal = __getobj__
        Decidim::ResourceLocatorPresenter.new(proposal).path
      end

      def display_mention
        link_to title, proposal_path
      end
    end
  end
end
