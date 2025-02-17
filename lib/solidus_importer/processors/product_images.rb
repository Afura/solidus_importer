# frozen_string_literal: true

module SolidusImporter
  module Processors
    class ProductImages < Base
      def call(context)
        @data = context.fetch(:data)
        return unless product_image?

        product = context.fetch(:product)
        process_images(product)
      end

      private

      def prepare_image
        attachment = URI.parse(@data['Image Src']).open({ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE})
        Spree::Image.new(attachment: attachment, alt: @data['Image Alt Text'], position: @data["Image Position"])
      end

      def process_images(product)
        # TODO:
        # destroying previous images should be configurable
        product.images.destroy_all
        product.images << prepare_image
      end

      def product_image?
        @product_image ||= @data['Image Src'].present?
      end
    end
  end
end
