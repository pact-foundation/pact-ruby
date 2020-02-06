module Pact
  module PactBroker
    class Notices < Array
      def before_verification_notices
        select { | notice | notice[:when].nil? || notice[:when].start_with?('before_verification') }
      end

      def before_verification_notices_text
        before_verification_notices.collect{ | notice | notice[:text] }
      end

      def after_verification_notices(success, published)
        select { | notice | notice[:when] == "after_verification:success_#{success}_published_#{published}" || notice[:when] == "after_verification" }
          .collect do | notice |
            notice.merge(:when => simplify_notice_when(notice[:when]))
          end
      end

      def after_verification_notices_text(success, published)
        after_verification_notices(success, published).collect{ | notice | notice[:text] }
      end

      def all_notices(success, published)
        before_verification_notices + after_verification_notices(success, published)
      end

      private

      def simplify_notice_when(when_key)
        when_key.split(":").first
      end
    end
  end
end
