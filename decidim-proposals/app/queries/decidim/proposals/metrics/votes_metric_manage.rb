# frozen_string_literal: true

module Decidim
  module Proposals
    module Metrics
      class VotesMetricManage < Decidim::MetricManage
        def initialize(day_string)
          super(day_string)
          @metric_name = "votes"
        end

        def with_context(organization)
          @organization = organization

          spaces = Decidim.participatory_space_manifests.flat_map do |manifest|
            manifest.participatory_spaces.call(@organization).public_spaces
          end
          components = Decidim::Component.where(participatory_space: spaces).published
          proposals = Decidim::Proposals::Proposal.where(component: components).except_withdrawn
          @query = Decidim::Proposals::ProposalVote.joins(proposal: [:component, :category]).where(proposal: proposals)
        end

        def query
          @query = @query.where("decidim_proposals_proposal_votes.created_at <= ?", end_time)
          @query = @query.group("decidim_categorizations.id", :participatory_space_type, :participatory_space_id, :decidim_proposal_id)
        end

        def cumulative
          @cumulative ||= @query.count
        end

        def quantity
          @quantity ||= @query.where("decidim_proposals_proposal_votes.created_at >= ?", start_time).count
        end

        def registry
          @registry = []
          cumulative.each do |key, cumulative_value|
            next if cumulative_value.zero?
            quantity_value = quantity[key] || 0
            category_id, space_type, space_id, proposal_id = key
            registry = Decidim::Metric.find_or_initialize_by(day: @day.to_s, metric_type: @metric_name,
                                                             organization: @organization, decidim_category_id: category_id,
                                                             participatory_space_type: space_type, participatory_space_id: space_id,
                                                             related_object_type: "Decidim::Propsals::Proposal", related_object_id: proposal_id)
            registry.assign_attributes(cumulative: cumulative_value, quantity: quantity_value)
            @registry << registry
          end
        end

        def registry!
          registry
          @registry.each(&:save!)
        end
      end
    end
  end
end
