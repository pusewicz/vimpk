# frozen_string_literal: true

module VimPK
  class CLI
    def self.start(args)
      VimPK::Update.run
    end
  end
end
