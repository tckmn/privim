-- Test argument list commands

local helpers = require('test.functional.helpers')(after_each)
local clear, execute, eq = helpers.clear, helpers.execute, helpers.eq
local eval, exc_exec, neq = helpers.eval, helpers.exc_exec, helpers.neq

if helpers.pending_win32(pending) then return end

describe('argument list commands', function()
  before_each(clear)

  local function init_abc()
    execute('args a b c')
    execute('next')
  end

  local function reset_arglist()
    execute('arga a | %argd')
  end

  local function assert_fails(cmd, err)
    neq(exc_exec(cmd):find(err), nil)
  end

  it('test that argidx() works', function()
    execute('args a b c')
    execute('last')
    eq(2, eval('argidx()'))
    execute('%argdelete')
    eq(0, eval('argidx()'))

    execute('args a b c')
    eq(0, eval('argidx()'))
    execute('next')
    eq(1, eval('argidx()'))
    execute('next')
    eq(2, eval('argidx()'))
    execute('1argdelete')
    eq(1, eval('argidx()'))
    execute('1argdelete')
    eq(0, eval('argidx()'))
    execute('1argdelete')
    eq(0, eval('argidx()'))
  end)

  it('test that argadd() works', function()
    execute('%argdelete')
    execute('argadd a b c')
    eq(0, eval('argidx()'))

    execute('%argdelete')
    execute('argadd a')
    eq(0, eval('argidx()'))
    execute('argadd b c d')
    eq(0, eval('argidx()'))

    init_abc()
    execute('argadd x')
    eq({'a', 'b', 'x', 'c'}, eval('argv()'))
    eq(1, eval('argidx()'))

    init_abc()
    execute('0argadd x')
    eq({'x', 'a', 'b', 'c'}, eval('argv()'))
    eq(2, eval('argidx()'))

    init_abc()
    execute('1argadd x')
    eq({'a', 'x', 'b', 'c'}, eval('argv()'))
    eq(2, eval('argidx()'))

    init_abc()
    execute('$argadd x')
    eq({'a', 'b', 'c', 'x'}, eval('argv()'))
    eq(1, eval('argidx()'))

    init_abc()
    execute('$argadd x')
    execute('+2argadd y')
    eq({'a', 'b', 'c', 'x', 'y'}, eval('argv()'))
    eq(1, eval('argidx()'))

    execute('%argd')
    execute('edit d')
    execute('arga')
    eq(1, eval('len(argv())'))
    eq('d', eval('get(argv(), 0, "")'))

    execute('%argd')
    execute('new')
    execute('arga')
    eq(0, eval('len(argv())'))
  end)

  it('test for [count]argument and [count]argdelete commands', function()
    reset_arglist()
    execute('let save_hidden = &hidden')
    execute('set hidden')
    execute('let g:buffers = []')
    execute('augroup TEST')
    execute([[au BufEnter * call add(buffers, expand('%:t'))]])
    execute('augroup END')

    execute('argadd a b c d')
    execute('$argu')
    execute('$-argu')
    execute('-argu')
    execute('1argu')
    execute('+2argu')

    execute('augroup TEST')
    execute('au!')
    execute('augroup END')

    eq({'d', 'c', 'b', 'a', 'c'}, eval('g:buffers'))

    execute('redir => result')
    execute('ar')
    execute('redir END')
    eq(1, eval([[result =~# 'a b \[c] d']]))

    execute('.argd')
    eq({'a', 'b', 'd'}, eval('argv()'))

    execute('-argd')
    eq({'a', 'd'}, eval('argv()'))

    execute('$argd')
    eq({'a'}, eval('argv()'))

    execute('1arga c')
    execute('1arga b')
    execute('$argu')
    execute('$arga x')
    eq({'a', 'b', 'c', 'x'}, eval('argv()'))

    execute('0arga Y')
    eq({'Y', 'a', 'b', 'c', 'x'}, eval('argv()'))

    execute('%argd')
    eq({}, eval('argv()'))

    execute('arga a b c d e f')
    execute('2,$-argd')
    eq({'a', 'f'}, eval('argv()'))

    execute('let &hidden = save_hidden')

    -- Setting the argument list should fail when the current buffer has
    -- unsaved changes
    execute('%argd')
    execute('enew!')
    execute('set modified')
    assert_fails('args x y z', 'E37:')
    execute('args! x y z')
    eq({'x', 'y', 'z'}, eval('argv()'))
    eq('x', eval('expand("%:t")'))

    execute('%argdelete')
    assert_fails('argument', 'E163:')
  end)

  it('test for 0argadd and 0argedit', function()
    reset_arglist()

    execute('arga a b c d')
    execute('2argu')
    execute('0arga added')
    eq({'added', 'a', 'b', 'c', 'd'}, eval('argv()'))

    execute('%argd')
    execute('arga a b c d')
    execute('2argu')
    execute('0arge edited')
    eq({'edited', 'a', 'b', 'c', 'd'}, eval('argv()'))

    execute('2argu')
    execute('arga third')
    eq({'edited', 'a', 'third', 'b', 'c', 'd'}, eval('argv()'))
  end)

  it('test for argc()', function()
    reset_arglist()
    eq(0, eval('argc()'))
    execute('argadd a b')
    eq(2, eval('argc()'))
  end)

  it('test for arglistid()', function()
    reset_arglist()
    execute('arga a b')
    eq(0, eval('arglistid()'))
    execute('split')
    execute('arglocal')
    eq(1, eval('arglistid()'))
    execute('tabnew | tabfirst')
    eq(0, eval('arglistid(2)'))
    eq(1, eval('arglistid(1, 1)'))
    eq(0, eval('arglistid(2, 1)'))
    eq(1, eval('arglistid(1, 2)'))
    execute('tabonly | only | enew!')
    execute('argglobal')
    eq(0, eval('arglistid()'))
  end)

  it('test for argv()', function()
    reset_arglist()
    eq({}, eval('argv()'))
    eq('', eval('argv(2)'))
    execute('argadd a b c d')
    eq('c', eval('argv(2)'))
  end)

  it('test for :argedit command', function()
    reset_arglist()
    execute('argedit a')
    eq({'a'}, eval('argv()'))
    eq('a', eval('expand("%:t")'))
    execute('argedit b')
    eq({'a', 'b'}, eval('argv()'))
    eq('b', eval('expand("%:t")'))
    execute('argedit a')
    eq({'a', 'b'}, eval('argv()'))
    eq('a', eval('expand("%:t")'))
    execute('argedit c')
    eq({'a', 'c', 'b'}, eval('argv()'))
    execute('0argedit x')
    eq({'x', 'a', 'c', 'b'}, eval('argv()'))
    execute('enew! | set modified')
    assert_fails('argedit y', 'E37:')
    execute('argedit! y')
    eq({'x', 'y', 'a', 'c', 'b'}, eval('argv()'))
    execute('%argd')
    -- Nvim allows unescaped spaces in filename on all platforms. #6010
    execute('argedit a b')
    eq({'a b'}, eval('argv()'))
  end)

  it('test for :argdelete command', function()
    reset_arglist()
    execute('args aa a aaa b bb')
    execute('argdelete a*')
    eq({'b', 'bb'}, eval('argv()'))
    eq('aa', eval('expand("%:t")'))
    execute('last')
    execute('argdelete %')
    eq({'b'}, eval('argv()'))
    assert_fails('argdelete', 'E471:')
    assert_fails('1,100argdelete', 'E16:')
    execute('%argd')
  end)

  it('test for the :next, :prev, :first, :last, :rewind commands', function()
    reset_arglist()
    execute('args a b c d')
    execute('last')
    eq(3, eval('argidx()'))
    assert_fails('next', 'E165:')
    execute('prev')
    eq(2, eval('argidx()'))
    execute('Next')
    eq(1, eval('argidx()'))
    execute('first')
    eq(0, eval('argidx()'))
    assert_fails('prev', 'E164:')
    execute('3next')
    eq(3, eval('argidx()'))
    execute('rewind')
    eq(0, eval('argidx()'))
    execute('%argd')
  end)
end)
