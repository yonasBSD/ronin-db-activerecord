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
require_relative 'model/importable'
require_relative 'model/has_unique_name'

require 'active_record'

module Ronin
  module DB
    #
    # Represents a user name and their associated {Credential credentials}
    # or {EmailAddress email addresses}.
    #
    class UserName < ActiveRecord::Base

      include Model
      include Model::Importable
      include Model::HasUniqueName

      self.table_name = 'ronin_user_names'

      # @!attribute [rw] id
      #   The primary key of the user name.
      #
      #   @return [Integer]
      attribute :id, :integer

      # @!attribute [r] created_at
      #   Tracks when the user-name was created.
      #
      #   @return [Time]
      attribute :created_at, :datetime

      # @!attribute [rw] credentials
      #   Any credentials belonging to the user.
      #
      #   @return [Array<Credential>]
      has_many :credentials, dependent: :destroy

      # @!attribute [rw] service_credentials
      #   The service credentials that use the user name.
      #
      #   @return [Array<ServiceCredential>]
      #
      #   @since 0.2.0
      has_many :service_credentials, through: :credentials

      # @!attribute [rw] web_credentials
      #   Any web credentials that use the user name.
      #
      #   @return [Array<WebCredential>]
      #
      #   @since 0.2.0
      has_many :web_credentials, through: :credentials

      # @!attribute [rw] passwords
      #   Any passwords used with the user name.
      #
      #   @return [Array<Password>]
      #
      #   @since 0.2.0
      has_many :passwords, through: :credentials

      # @!attribute [rw] email_addresses
      #   The email addresses of the user.
      #
      #   @return [Array<EmailAddress>]
      has_many :email_addresses, dependent: :destroy

      # @!attribute [rw] notes
      #   The associated notes.
      #
      #   @return [Array<Note>]
      #
      #   @since 0.2.0
      has_many :notes, dependent: :destroy

      #
      # Queries all user names that are associated with the password.
      #
      # @param [String] password
      #   The plain-text password.
      #
      # @return [Array<UserName>]
      #   The user names that are associated with the password.
      #
      # @api public
      #
      # @since 0.2.0
      #
      def self.with_password(password)
        joins(credentials: :password).where(
          credentials: {
            ronin_passwords: {
              plain_text: password
            }
          }
        )
      end

      #
      # Looks up the user name.
      #
      # @param [String] name
      #   The user name to lookup.
      #
      # @return [UserName, nil]
      #   The found user name.
      #
      def self.lookup(name)
        find_by(name: name)
      end

      #
      # Imports a user name.
      #
      # @param [String] name
      #   The user name to import.
      #
      # @return [UserName]
      #   The imported user name.
      #
      def self.import(name)
        create(name: name)
      end

    end
  end
end

require_relative 'credential'
require_relative 'password'
require_relative 'email_address'
require_relative 'note'
