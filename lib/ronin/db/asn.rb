#
# ronin-db-activerecord - ActiveRecord backend for the Ronin Database.
#
# Copyright (c) 2022 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This file is part of ronin-db-activerecord.
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

require 'ronin/db/model'

module Ronin
  module DB
    #
    # Represents an ASN range.
    #
    class ASN < ActiveRecord::Base

      include Model

      # @!attribute [rw] id
      #   The primary key of the ASN range.
      #
      #   @return [Integer]
      attribute :id, :integer

      # @!attribute [rw] version
      #   Whether the ASN range represents an IPv4 or IPv6 range.
      #
      #   @return [Integer]
      attribute :version, :integer
      validates :version, presence:  true,
                          inclusion: {in: [4, 6]}

      # @!attribute [rw] range_start
      #   The starting IP address of the ASN range.
      #
      #   @return [String]
      attribute :range_start, :string
      validates :range_start, presence: true

      # @!attribute [rw] range_end
      #   The ending IP address of the ASN range.
      #
      #   @return [String]
      attribute :range_end, :string
      validates :range_end, presence: true

      # @!attribute [r] range_start_hton
      #   The starting IP address of the ASN range, but in network byte-order.
      #
      #   @return [String]
      attribute :range_start_hton, :binary

      # @!attribute [r] range_end_hton
      #   The ending IP address of the ASN range, but in network byte-order.
      #
      #   @return [String]
      attribute :range_end_hton, :binary

      before_save :set_hton

      # @!attribute [rw] number
      #   The ASN number.
      #
      #   @return [Integer]
      attribute :number, :integer
      validates :number, presence:   true,
                         uniqueness: {scope: [:range_start, :range_end]}

      # @!attribute [rw] country_code
      #   The country code of the ASN.
      #
      #   @return [String]
      attribute :country_code, :string

      # @!attribute [rw] name
      #   The organization the ASN is currently assigned to.
      #
      #   @return [String]
      attribute :name, :string

      #
      # Queries the ASN that contains the given IP address.
      #
      # @param [IPAddr, String] ip
      #
      # @return [ASN, nil]
      #
      def self.containing_ip(ip)
        ip = IPAddr.new(ip) unless ip.kind_of?(IPAddr)
        ip_hton = ip.hton

        range_start_hton = self.arel_table[:range_start_hton]
        range_end_hton  = self.arel_table[:range_end_hton]

        where(range_start_hton.lteq(ip_hton).and(range_end_hton.gteq(ip_hton))).first
      end

      #
      # @return [IPAddr, nil]
      #
      def range_startaddr
        @range_startaddr ||= if self.range_start
                            IPAddr.new(self.range_start)
                          end
      end

      #
      # @return [IPAddr, nil]
      #
      def range_endaddr
        @range_endaddr ||= if self.range_end
                           IPAddr.new(self.range_end)
                         end
      end

      private

      #
      # Sets the `range_start_hton` and `range_end_hton` attributes.
      #
      def set_hton
        self.range_start_hton = range_startaddr.hton
        self.range_end_hton   = range_endaddr.hton
      end

    end
  end
end