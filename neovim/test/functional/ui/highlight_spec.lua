local helpers = require('test.functional.helpers')(after_each)
local Screen = require('test.functional.ui.screen')
local os = require('os')
local clear, feed, insert = helpers.clear, helpers.feed, helpers.insert
local execute, request, eq = helpers.execute, helpers.request, helpers.eq

if helpers.pending_win32(pending) then return end

describe('color scheme compatibility', function()
  before_each(function()
    clear()
  end)

  it('t_Co is set to 256 by default', function()
    eq('256', request('vim_eval', '&t_Co'))
    request('nvim_set_option', 't_Co', '88')
    eq('88', request('vim_eval', '&t_Co'))
  end)
end)

describe('manual syntax highlight', function()
  -- When using manual syntax highlighting, it should be preserved even when
  -- switching buffers... bug did only occur without :set hidden
  -- Ref: vim patch 7.4.1236
  local screen

  before_each(function()
    clear()
    screen = Screen.new(20,5)
    screen:attach()
    --syntax highlight for vimcscripts "echo"
    screen:set_default_attr_ids( {
      [0] = {bold=true, foreground=Screen.colors.Blue},
      [1] = {bold=true, foreground=Screen.colors.Brown}
    } )
  end)

  after_each(function()
    screen:detach()
    os.remove('Xtest-functional-ui-highlight.tmp.vim')
  end)

  it("works with buffer switch and 'hidden'", function()
    execute('e tmp1.vim')
    execute('e Xtest-functional-ui-highlight.tmp.vim')
    execute('filetype on')
    execute('syntax manual')
    execute('set ft=vim')
    execute('set syntax=ON')
    feed('iecho 1<esc>0')

    execute('set hidden')
    execute('w')
    execute('bn')
    execute('bp')
    screen:expect([[
      {1:^echo} 1              |
      {0:~                   }|
      {0:~                   }|
      {0:~                   }|
      <f 1 --100%-- col 1 |
    ]])
  end)

  it("works with buffer switch and 'nohidden'", function()
    execute('e tmp1.vim')
    execute('e Xtest-functional-ui-highlight.tmp.vim')
    execute('filetype on')
    execute('syntax manual')
    execute('set ft=vim')
    execute('set syntax=ON')
    feed('iecho 1<esc>0')

    execute('set nohidden')
    execute('w')
    execute('bn')
    execute('bp')
    screen:expect([[
      {1:^echo} 1              |
      {0:~                   }|
      {0:~                   }|
      {0:~                   }|
      <ht.tmp.vim" 1L, 7C |
    ]])
  end)
end)


describe('Default highlight groups', function()
  -- Test the default attributes for highlight groups shown by the :highlight
  -- command
  local screen

  before_each(function()
    clear()
    screen = Screen.new()
    screen:attach()
  end)

  after_each(function()
    screen:detach()
  end)

  it('window status bar', function()
    screen:set_default_attr_ids({
      [0] = {bold=true, foreground=Screen.colors.Blue},
      [1] = {reverse = true, bold = true},  -- StatusLine
      [2] = {reverse = true}                -- StatusLineNC
    })
    execute('sp', 'vsp', 'vsp')
    screen:expect([[
      ^                    {2:|}                {2:|}               |
      {0:~                   }{2:|}{0:~               }{2:|}{0:~              }|
      {0:~                   }{2:|}{0:~               }{2:|}{0:~              }|
      {0:~                   }{2:|}{0:~               }{2:|}{0:~              }|
      {0:~                   }{2:|}{0:~               }{2:|}{0:~              }|
      {0:~                   }{2:|}{0:~               }{2:|}{0:~              }|
      {1:[No Name]            }{2:[No Name]        [No Name]      }|
                                                           |
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {2:[No Name]                                            }|
                                                           |
    ]])
    -- navigate to verify that the attributes are properly moved
    feed('<c-w>j')
    screen:expect([[
                          {2:|}                {2:|}               |
      {0:~                   }{2:|}{0:~               }{2:|}{0:~              }|
      {0:~                   }{2:|}{0:~               }{2:|}{0:~              }|
      {0:~                   }{2:|}{0:~               }{2:|}{0:~              }|
      {0:~                   }{2:|}{0:~               }{2:|}{0:~              }|
      {0:~                   }{2:|}{0:~               }{2:|}{0:~              }|
      {2:[No Name]            [No Name]        [No Name]      }|
      ^                                                     |
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {1:[No Name]                                            }|
                                                           |
    ]])
    -- note that when moving to a window with small width nvim will increase
    -- the width of the new active window at the expense of a inactive window
    -- (upstream vim has the same behavior)
    feed('<c-w>k<c-w>l')
    screen:expect([[
                          {2:|}^                    {2:|}           |
      {0:~                   }{2:|}{0:~                   }{2:|}{0:~          }|
      {0:~                   }{2:|}{0:~                   }{2:|}{0:~          }|
      {0:~                   }{2:|}{0:~                   }{2:|}{0:~          }|
      {0:~                   }{2:|}{0:~                   }{2:|}{0:~          }|
      {0:~                   }{2:|}{0:~                   }{2:|}{0:~          }|
      {2:[No Name]            }{1:[No Name]            }{2:[No Name]  }|
                                                           |
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {2:[No Name]                                            }|
                                                           |
    ]])
    feed('<c-w>l')
    screen:expect([[
                          {2:|}           {2:|}^                    |
      {0:~                   }{2:|}{0:~          }{2:|}{0:~                   }|
      {0:~                   }{2:|}{0:~          }{2:|}{0:~                   }|
      {0:~                   }{2:|}{0:~          }{2:|}{0:~                   }|
      {0:~                   }{2:|}{0:~          }{2:|}{0:~                   }|
      {0:~                   }{2:|}{0:~          }{2:|}{0:~                   }|
      {2:[No Name]            [No Name]   }{1:[No Name]           }|
                                                           |
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {2:[No Name]                                            }|
                                                           |
    ]])
    feed('<c-w>h<c-w>h')
    screen:expect([[
      ^                    {2:|}                    {2:|}           |
      {0:~                   }{2:|}{0:~                   }{2:|}{0:~          }|
      {0:~                   }{2:|}{0:~                   }{2:|}{0:~          }|
      {0:~                   }{2:|}{0:~                   }{2:|}{0:~          }|
      {0:~                   }{2:|}{0:~                   }{2:|}{0:~          }|
      {0:~                   }{2:|}{0:~                   }{2:|}{0:~          }|
      {1:[No Name]            }{2:[No Name]            [No Name]  }|
                                                           |
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {2:[No Name]                                            }|
                                                           |
    ]])
  end)

  it('insert mode text', function()
    feed('i')
    screen:expect([[
      ^                                                     |
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {1:-- INSERT --}                                         |
    ]], {[0] = {bold=true, foreground=Screen.colors.Blue},
    [1] = {bold = true}})
  end)

  it('end of file markers', function()
    screen:expect([[
      ^                                                     |
      {1:~                                                    }|
      {1:~                                                    }|
      {1:~                                                    }|
      {1:~                                                    }|
      {1:~                                                    }|
      {1:~                                                    }|
      {1:~                                                    }|
      {1:~                                                    }|
      {1:~                                                    }|
      {1:~                                                    }|
      {1:~                                                    }|
      {1:~                                                    }|
                                                           |
    ]], {[1] = {bold = true, foreground = Screen.colors.Blue}})
  end)

  it('"wait return" text', function()
    feed(':ls<cr>')
    screen:expect([[
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      :ls                                                  |
        1 %a   "[No Name]"                    line 1       |
      {1:Press ENTER or type command to continue}^              |
    ]], {[0] = {bold=true, foreground=Screen.colors.Blue},
    [1] = {bold = true, foreground = Screen.colors.SeaGreen}})
    feed('<cr>') --  skip the "Press ENTER..." state or tests will hang
  end)
  it('can be cleared and linked to other highlight groups', function()
    execute('highlight clear ModeMsg')
    feed('i')
    screen:expect([[
      ^                                                     |
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      -- INSERT --                                         |
    ]], {[0] = {bold=true, foreground=Screen.colors.Blue},
    [1] = {bold=true}})
    feed('<esc>')
    execute('highlight CustomHLGroup guifg=red guibg=green')
    execute('highlight link ModeMsg CustomHLGroup')
    feed('i')
    screen:expect([[
      ^                                                     |
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {1:-- INSERT --}                                         |
    ]], {[0] = {bold=true, foreground=Screen.colors.Blue},
    [1] = {foreground = Screen.colors.Red, background = Screen.colors.Green}})
  end)
  it('can be cleared by assigning NONE', function()
    execute('syn keyword TmpKeyword neovim')
    execute('hi link TmpKeyword ErrorMsg')
    insert('neovim')
    screen:expect([[
      {1:neovi^m}                                               |
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
                                                           |
    ]], {
      [0] = {bold=true, foreground=Screen.colors.Blue},
      [1] = {foreground = Screen.colors.White, background = Screen.colors.Red}
    })
    execute("hi ErrorMsg term=NONE cterm=NONE ctermfg=NONE ctermbg=NONE"
            .. " gui=NONE guifg=NONE guibg=NONE guisp=NONE")
    screen:expect([[
      neovi^m                                               |
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
      {0:~                                                    }|
                                                           |
    ]], {[0] = {bold=true, foreground=Screen.colors.Blue}})
  end)
end)

describe('guisp (special/undercurl)', function()
  local screen

  before_each(function()
    clear()
    screen = Screen.new(25,10)
    screen:attach()
  end)

  it('can be set and is applied like foreground or background', function()
    execute('syntax on')
    execute('syn keyword TmpKeyword neovim')
    execute('syn keyword TmpKeyword1 special')
    execute('syn keyword TmpKeyword2 specialwithbg')
    execute('syn keyword TmpKeyword3 specialwithfg')
    execute('hi! Awesome guifg=red guibg=yellow guisp=red')
    execute('hi! Awesome1 guisp=red')
    execute('hi! Awesome2 guibg=yellow guisp=red')
    execute('hi! Awesome3 guifg=red guisp=red')
    execute('hi link TmpKeyword Awesome')
    execute('hi link TmpKeyword1 Awesome1')
    execute('hi link TmpKeyword2 Awesome2')
    execute('hi link TmpKeyword3 Awesome3')
    insert([[
      neovim
      awesome neovim
      wordcontainingneovim
      special
      specialwithbg
      specialwithfg
      ]])
    feed('Go<tab>neovim tabbed')
    screen:expect([[
      {1:neovim}                   |
      awesome {1:neovim}           |
      wordcontainingneovim     |
      {2:special}                  |
      {3:specialwithbg}            |
      {4:specialwithfg}            |
                               |
              {1:neovim} tabbed^    |
      {0:~                        }|
      {5:-- INSERT --}             |
    ]],{
      [0] = {bold=true, foreground=Screen.colors.Blue},
      [1] = {background = Screen.colors.Yellow, foreground = Screen.colors.Red,
             special = Screen.colors.Red},
      [2] = {special = Screen.colors.Red},
      [3] = {special = Screen.colors.Red, background = Screen.colors.Yellow},
      [4] = {foreground = Screen.colors.Red, special = Screen.colors.Red},
      [5] = {bold=true},
    })

  end)
end)

describe("'cursorline' with 'listchars'", function()
  local screen

  before_each(function()
    clear()
    screen = Screen.new(20,5)
    screen:attach()
  end)

  after_each(function()
    screen:detach()
  end)

  it("'cursorline' and 'cursorcolumn'", function()
    screen:set_default_attr_ids({
      [0] = {bold=true, foreground=Screen.colors.Blue},
      [1] = {background=Screen.colors.Grey90}
    })
    execute('highlight clear ModeMsg')
    execute('set cursorline')
    feed('i')
    screen:expect([[
      {1:^                    }|
      {0:~                   }|
      {0:~                   }|
      {0:~                   }|
      -- INSERT --        |
    ]])
    feed('abcdefg<cr>kkasdf')
    screen:expect([[
      abcdefg             |
      {1:kkasdf^              }|
      {0:~                   }|
      {0:~                   }|
      -- INSERT --        |
    ]])
    feed('<esc>')
    screen:expect([[
      abcdefg             |
      {1:kkasd^f              }|
      {0:~                   }|
      {0:~                   }|
                          |
    ]])
    execute('set nocursorline')
    screen:expect([[
      abcdefg             |
      kkasd^f              |
      {0:~                   }|
      {0:~                   }|
      :set nocursorline   |
    ]])
    feed('k')
    screen:expect([[
      abcde^fg             |
      kkasdf              |
      {0:~                   }|
      {0:~                   }|
      :set nocursorline   |
    ]])
    feed('jjji<cr><cr><cr><esc>')
    screen:expect([[
      kkasd               |
                          |
                          |
      ^f                   |
                          |
    ]])
    execute('set cursorline')
    execute('set cursorcolumn')
    feed('kkiabcdefghijk<esc>hh')
    screen:expect([[
      kkasd   {1: }           |
      {1:abcdefgh^ijk         }|
              {1: }           |
      f       {1: }           |
                          |
    ]])
    feed('khh')
    screen:expect([[
      {1:kk^asd               }|
      ab{1:c}defghijk         |
        {1: }                 |
      f {1: }                 |
                          |
    ]])
  end)

  it("'cursorline' and with 'listchar' option: space, eol, tab, and trail", function()
    screen:set_default_attr_ids({
      [1] = {background=Screen.colors.Grey90},
      [2] = {
        foreground=Screen.colors.Red,
        background=Screen.colors.Grey90,
      },
      [3] = {
        background=Screen.colors.Grey90,
        foreground=Screen.colors.Blue,
        bold=true,
      },
      [4] = {
        foreground=Screen.colors.Blue,
        bold=true,
      },
      [5] = {
        foreground=Screen.colors.Red,
      },
    })
    execute('highlight clear ModeMsg')
    execute('highlight SpecialKey guifg=#FF0000')
    execute('set cursorline')
    execute('set tabstop=8')
    execute('set listchars=space:.,eol:¬,tab:>-,extends:>,precedes:<,trail:* list')
    feed('i\t abcd <cr>\t abcd <cr><esc>k')
    screen:expect([[
      {5:>-------.}abcd{5:*}{4:¬}     |
      {2:^>-------.}{1:abcd}{2:*}{3:¬}{1:     }|
      {4:¬}                   |
      {4:~                   }|
                          |
    ]])
    feed('k')
    screen:expect([[
      {2:^>-------.}{1:abcd}{2:*}{3:¬}{1:     }|
      {5:>-------.}abcd{5:*}{4:¬}     |
      {4:¬}                   |
      {4:~                   }|
                          |
    ]])
    execute('set nocursorline')
    screen:expect([[
      {5:^>-------.}abcd{5:*}{4:¬}     |
      {5:>-------.}abcd{5:*}{4:¬}     |
      {4:¬}                   |
      {4:~                   }|
      :set nocursorline   |
    ]])
    execute('set nowrap')
    feed('ALorem ipsum dolor sit amet<ESC>0')
    screen:expect([[
      {5:^>-------.}abcd{5:.}Lorem{4:>}|
      {5:>-------.}abcd{5:*}{4:¬}     |
      {4:¬}                   |
      {4:~                   }|
                          |
    ]])
    execute('set cursorline')
    screen:expect([[
      {2:^>-------.}{1:abcd}{2:.}{1:Lorem}{4:>}|
      {5:>-------.}abcd{5:*}{4:¬}     |
      {4:¬}                   |
      {4:~                   }|
      :set cursorline     |
    ]])
    feed('$')
    screen:expect([[
      {4:<}{1:r}{2:.}{1:sit}{2:.}{1:ame^t}{3:¬}{1:        }|
      {4:<}                   |
      {4:<}                   |
      {4:~                   }|
      :set cursorline     |
    ]])
    feed('G')
    screen:expect([[
      {5:>-------.}abcd{5:.}Lorem{4:>}|
      {5:>-------.}abcd{5:*}{4:¬}     |
      {3:^¬}{1:                   }|
      {4:~                   }|
      :set cursorline     |
    ]])
  end)

  it("'listchar' in visual mode", function()
    screen:set_default_attr_ids({
      [1] = {background=Screen.colors.Grey90},
      [2] = {
        foreground=Screen.colors.Red,
        background=Screen.colors.Grey90,
      },
      [3] = {
        background=Screen.colors.Grey90,
        foreground=Screen.colors.Blue,
        bold=true,
      },
      [4] = {
        foreground=Screen.colors.Blue,
        bold=true,
      },
      [5] = {
        foreground=Screen.colors.Red,
      },
      [6] = {
        background=Screen.colors.LightGrey,
      },
      [7] = {
        background=Screen.colors.LightGrey,
        foreground=Screen.colors.Red,
      },
      [8] = {
        background=Screen.colors.LightGrey,
        foreground=Screen.colors.Blue,
        bold=true,
      },
    })
    execute('highlight clear ModeMsg')
    execute('highlight SpecialKey guifg=#FF0000')
    execute('set cursorline')
    execute('set tabstop=8')
    execute('set nowrap')
    execute('set listchars=space:.,eol:¬,tab:>-,extends:>,precedes:<,trail:* list')
    feed('i\t abcd <cr>\t abcd Lorem ipsum dolor sit amet<cr><esc>kkk0')
    screen:expect([[
      {2:^>-------.}{1:abcd}{2:*}{3:¬}{1:     }|
      {5:>-------.}abcd{5:.}Lorem{4:>}|
      {4:¬}                   |
      {4:~                   }|
                          |
    ]])
    feed('lllvj')
    screen:expect([[
      {5:>-------.}a{6:bcd}{7:*}{8:¬}     |
      {7:>-------.}{6:a}^bcd{5:.}Lorem{4:>}|
      {4:¬}                   |
      {4:~                   }|
      -- VISUAL --        |
    ]])
    feed('<esc>V')
    screen:expect([[
      {5:>-------.}abcd{5:*}{4:¬}     |
      {7:>-------.}{6:a}^b{6:cd}{7:.}{6:Lorem}{4:>}|
      {4:¬}                   |
      {4:~                   }|
      -- VISUAL LINE --   |
    ]])
    feed('<esc>$')
    screen:expect([[
      {4:<}                   |
      {4:<}{1:r}{2:.}{1:sit}{2:.}{1:ame^t}{3:¬}{1:        }|
      {4:<}                   |
      {4:~                   }|
                          |
    ]])
  end)
end)
