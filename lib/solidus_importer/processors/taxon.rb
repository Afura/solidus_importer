# frozen_string_literal: true

module SolidusImporter
  module Processors
    class Taxon < Base
      attr_accessor :product, :taxonomy

      def call(context)
        @data = context.fetch(:data)

        self.product = context.fetch(:product)

        process_taxons_type
        process_taxons_brand
        process_taxons_tags
      end

      private

      def options
        @options ||= {
          type_taxonomy: Spree::Taxonomy.find_or_create_by(name: 'Categories'),
          tags_taxonomy: Spree::Taxonomy.find_or_create_by(name: 'Tags'),
          brands_taxonomy: Spree::Taxonomy.find_or_create_by(name: 'Brands')
        }
      end

      def process_taxons_type
        return unless type

        add_taxon(prepare_taxon(type, options[:type_taxonomy]))
      end

      def process_taxons_brand
        return unless brand

        add_taxon(prepare_taxon(brand, options[:brands_taxonomy]))
      end

      def process_taxons_tags
        tags.map do |tag|
          add_taxon(prepare_taxon(tag, options[:tags_taxonomy]))
        end
      end

      def add_taxon(taxon)
        product.taxons << taxon unless product.taxons.include?(taxon)
      end

      def prepare_taxon(name, taxonomy)
        # this doesn't work well when it has to create the taxon
        # as it will create it without a parent (the parent should be
        # the root taxon for that taxonomy)
        Spree::Taxon.find_or_initialize_by(
          name: name,
          taxonomy_id: taxonomy.id,
          parent_id: taxonomy.root.id
        )
      end

      def tags
        return [] unless @data['Tags'].presence

        @data['Tags'].split(',').map(&:strip)
      end

      def type
        @data['Type'].presence
      end

      def brand
        @data['Vendor'].presence
      end
    end
  end
end
