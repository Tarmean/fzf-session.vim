function! session#session(bang, ...)
        let [query, args] = (a:0 && type(a:1) == type('')) ? [a:1, a:000[1:]] : ['', a:000]
        let callback = a:bang ? 's:session_sink_bang' : 's:session_sink_nobang'
        return s:fzf('load_session', {
        \    'source':  s:session_source(query) + [s:new_session_prompt],
        \   'sink*':   function(callback),
        \   'options': ['+m', '--multi', '--tiebreak=index', '--prompt', 'Load Session> ', '--ansi', '--extended', '--nth=2..', '--layout=reverse-list', '--tabstop=1', '--expect=ctrl-d', '--header', 'Press CTRL-D to delete a session'],
        \    }, 0)
endfunction
let s:new_session_prompt = '	  |  New Session'
let g:session_dir = expand('~/.vim/sessions/')

let s:default_action = { 'ctrl-d': 'delete'}

function! session#delete_session(...)
        let [query, args] = (a:0 && type(a:1) == type('')) ? [a:1, a:000[1:]] : ['', a:000]
        return s:fzf('delete_session', {
        \   'source':  s:session_source(query),
        \   'sink*':   function('s:delete_session_sink'),
        \   'options': ['+m', '--tiebreak=index', '--multi', '--prompt', 'Delete Session> ', '--ansi', '--extended', '--nth=2..', '--layout=reverse-list', '--tabstop=1'],
        \}, 0)
endfunction
function! s:fzf(a,b,c)
    call fzf#run(fzf#wrap(a:a,a:b,a:c))
endfunc


function! s:format_session_line(idx, str)
    let mod_time = s:rel_time(getftime(a:str))
    let name = fnamemodify(a:str, ':t:r')
    let fmt_str = "%s\t%2d ". printf("\t%%-%ds%%s", min([80, winwidth('')-12]) - len(mod_time))
    let cur_session = get(g:, 'this_obsession', v:this_session)
    return printf(fmt_str,s:get_session_type(a:str), a:idx+1, name, mod_time)
endfunction
function! s:get_session_type(str)
    if (exists('g:this_obsession') && fnameescape(a:str) == g:this_obsession)
        return '*'
    elseif (v:this_session == fnameescape(a:str))
        return 'P'
    else
        return ' '
    endif
endfunc

function! s:rel_time(time)
    let t = localtime() - a:time
    let orders = [[60, 'Second'], [60, 'Minute'], [24, 'Hour'], [7, 'Day'], [4, 'Week'], [12, 'Month'], [0, 'Year']]
    for [fits, name] in orders
        let cur_format = printf("%d %s%s Ago", t, name, t == 1 ? '' : 's')
        if t < fits
            break
        endif
        let t = t / fits
    endfor
    return cur_format
endfunction

function! s:parse_session_name(line)
    if a:line == s:new_session_prompt
        let session_name =  input('Session Name: ')
        if (empty(session_name))
            return ''
        endif
        return g:session_dir . session_name. '.vim'
    else
        return s:extract_name(a:line)
    endif
endfunc
function! s:extract_name(line)
    let session_idx = str2nr(split(a:line, "\t", 1)[1])
    return s:session_paths[session_idx-1]
endfunc
function! s:session_sink_bang(input)
    call s:session_sink('!', a:input)
endfunc
function! s:session_sink_nobang(input)
    call s:session_sink('', a:input)
endfunc
function! s:session_sink(bang, input)
  if len(a:input) != 2 
      return
  endif
  let [action, lines] = a:input
  if type(lines) == type("")
      let lines = [lines]
  endif
  if action == ''
      if (len(lines) != 1)
          throw "Can't delete concepts"
      endif
      let session_name = s:parse_session_name(lines[0])
      if !empty(session_name)
          call session_utils#synchronize_session(a:bang, session_name)
      end
  elseif action == 'ctrl-d'
      for line in lines
          if (line == s:new_session_prompt)
              throw "Can't delete concepts"
          endif
          let session_name = s:extract_name(line)
          call session_utils#delete_session(session_name)
      endfor
  endif
endfunc



function! s:compare_times(b, a)
    let ta = getftime(a:a)
    let tb = getftime(a:b)
    return ta == tb ? 0 : ta > tb ? 1 : -1
endfunc
function! s:session_source(patt)
    let cur_session = get(g:, 'this_obsession', v:this_session)
    let s:session_paths = split(globpath(g:session_dir, '*.vim'), '\n')
    let s:session_paths = sort(s:session_paths, "s:compare_times")
    let paths = copy(s:session_paths)
    let formatted = map(paths, 's:format_session_line(v:key, v:val)')
    return formatted
endfunction
