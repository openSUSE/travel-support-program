# frozen_string_literal: true

# put logic in this file or initializer/carrierwave.rb
if defined?(CarrierWave)
  AttachmentUploader
  CarrierWave::Uploader::Base.descendants.each do |klass|
    next if klass.anonymous?

    klass.class_eval do
      def cache_dir
        "#{Rails.root}/public/spec/uploads/tmp"
      end

      def store_dir
        "#{Rails.root}/public/spec/uploads/#{model.class.to_s.underscore}/#{mounted_as}"
      end
    end
  end
end
