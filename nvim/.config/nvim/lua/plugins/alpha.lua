return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- Load alpha with error handling
    local status_ok, alpha = pcall(require, "alpha")
    if not status_ok then
      return
    end

    -- Setup dashboard theme
    local dashboard = require("alpha.themes.dashboard")

    dashboard.file_icons = "devicons"

    -- Custom header with ASCII art and a welcome message
    dashboard.section.header.val = {
      [[                                         )  (  (    (                      ]],
      [[                                         (  )  () @@  )  (( (              ]],
      [[                                     (      (  )( @@  (  )) ) (            ]],
      [[                                   (    (  ( ()( /---\   (()( (            ]],
      [[     _______                            )  ) )(@ !O O! )@@  ( ) ) )        ]],
      [[    <   ____)                      ) (  ( )( ()@ \ o / (@@@@@ ( ()( )      ]],
      [[ /--|  |(  o|                     (  )  ) ((@@(@@ !o! @@@@(@@@@@)() (      ]],
      [[|   >   \___|                      ) ( @)@@)@ /---\-/---\ )@@@@@()( )      ]],
      [[|  /---------+                    (@@@@)@@@( // /-----\ \\ @@@)@@@@@(  .    ]],
      [[| |    \ =========______/|@@@@@@@@@@@@@(@@@ // @ /---\ @ \\ @(@@@(@@@ .  .  ]],
      [[|  \   \\=========------\|@@@@@@@@@@@@@@@@@ O @@@ /-\ @@@ O @@(@@)@@ @   .  ]],
      [[|   \   \----+--\-)))           @@@@@@@@@@ !! @@@@ % @@@@ !! @@)@@@ .. .    ]],
      [[|   |\______|_)))/             .    @@@@@@ !! @@ /---\ @@ !! @@(@@@ @ . .   ]],
      [[ \__==========           *        .    @@ /MM  /\O   O/\  MM\ @@@@@@@. .    ]],
      [[    |   |-\   \          (       .      @ !!!  !! \-/ !!  !!! @@@@@ .       ]],
      [[    |   |  \   \          )   ))  )(   .  @@@@ !!     !!  .(. @.  .. .      ]],
      [[    |   |   \   \        (    /   .(  . \)). ( |O  )( O! @@@@ . )      .    ]],
      [[    |   |   /   /         ) (      )).  ((  .) !! ((( !! @@ (. ((. .   .    ]],
      [[    |   |  /   /   ()  ))   ))   .( ( ( ) ). ( !!  )( !! ) ((   ))  ..      ]],
      [[    |   |_<   /   ( ) ( (  ) )   (( )  )).) ((/ |  (  | \(  )) ((. ).       ]],
      [[____<_____\\__\__(___)_))_((_(____))__(_(___.oooO_____Oooo.(_(_)_)((_       ]],
      [[=========================================================================    ]],
    }

    -- Button configuration
    dashboard.section.buttons.val = {
      dashboard.button("f", "👽  Find Files", ":Telescope find_files <CR>"),
      dashboard.button("e", "🎄  New File", ":ene <BAR> startinsert <CR>"),
      dashboard.button("r", "🧙  Recent Files", ":Telescope oldfiles <CR>"),
      dashboard.button("t", "🛸  Search Text", ":Telescope live_grep <CR>"),
      dashboard.button("q", "🎃  Quit", ":qa<CR>"),
    }

    -- Footer setup with a custom message
    local function footer()
      return "Welcome home Aphexlog"
    end
    dashboard.section.footer.val = footer()

    -- Setting highlight groups
    dashboard.section.header.opts.hl = "Include"
    dashboard.section.buttons.opts.hl = "Keyword"
    dashboard.section.footer.opts.hl = "Type"

    -- Additional options and setup
    dashboard.opts.opts.noautocmd = true

    -- Initialize alpha with the configured dashboard
    alpha.setup(dashboard.opts)
  end,
}
