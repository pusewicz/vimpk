# frozen_string_literal: true
# rbs_inline: enabled

module VimPK
  module Commands
    autoload :Install, "vimpk/commands/install"
    autoload :List, "vimpk/commands/list"
    autoload :Move, "vimpk/commands/move"
    autoload :Remove, "vimpk/commands/remove"
    autoload :Update, "vimpk/commands/update"
  end
end
