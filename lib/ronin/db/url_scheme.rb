# frozen_string_literal: true
#
# ronin-db-activerecord - ActiveRecord backend for the Ronin Database.
#
# Copyright (c) 2022-2025 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# ronin-db-activerecord is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ronin-db-activerecord is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with ronin-db-activerecord.  If not, see <https://www.gnu.org/licenses/>.
#

require_relative 'model'
require_relative 'model/has_unique_name'

require 'active_record'

module Ronin
  module DB
    #
    # Represents a {URL} scheme.
    #
    class URLScheme < ActiveRecord::Base

      include Model
      include Model::HasUniqueName

      self.table_name = 'ronin_url_schemes'

      # @!attribute [rw] id
      #   The primary key of the URL scheme.
      #
      #   @return [Integer]
      attribute :id, :integer

      # @!attribute [rw] urls
      #   The URLs that use the scheme.
      #
      #   @return [Array<URL>]
      has_many :urls, class_name: 'URL',
                      foreign_key: :scheme_id

      #
      # The HTTP URL Scheme
      #
      # @return [URLScheme]
      #
      def self.http
        where(name: 'http').first
      end

      #
      # The HTTPS URL Scheme
      #
      # @return [URLScheme]
      #
      def self.https
        where(name: 'https').first
      end

      #
      # The FTP URL Scheme
      #
      # @return [URLScheme]
      #
      def self.ftp
        where(name: 'ftp').first
      end

    end
  end
end
