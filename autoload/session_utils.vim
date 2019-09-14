if !exists('g:session#unload_old_sessions')
    let g:session#unload_old_sessions = v:true
endif
if !exists('g:session#save_terminals')
    let g:session#save_terminals = v:true
endif
function! session_utils#synchronize_session(bang, session)
    let session = fnameescape(a:session)

    let should_load_file = s:should_load_session(session)
    if should_load_file == 'abort'
        return
    elseif should_load_file == 'pause'
        call s:pause_obsession()
        return
    endif

    call s:save_old_session()
    call s:pause_obsession()
    try
        if should_load_file == 'yes'
            call session_utils#load_session(a:bang, session)
        endif
        call s:mksession(session)
        call s:unpause_obsession(session)
    catch
        echom v:errmsg
        call getchar()
    endtry
endfunction
function! session_utils#load_session(bang, session)
    call s:unload_session(a:bang)
    try
        call s:load_session(a:session)
    catch
        echom 'error in loading: ' . v:errmsg
        call getchar()
    endtry
endfunc
function! s:unload_session(bang)
    if !exists('g:session#unload_old_sessions') || empty(g:session#unload_old_sessions)
        return
    endif
    if (tabpagenr('$') > 1)
        execute 'tabonly' . a:bang
    endif
    if winnr('$') > 1
        execute 'only' . a:bang
    endif
    execute 'enew' . a:bang
    let last_buf = bufnr('')
    for b in getbufinfo()
        let g:last = b
        let bufnr = b['bufnr']
        let buf_name = b['name']
        let is_listed = b['name']
        let is_loaded = b['name']
        if !is_loaded || (bufnr == last_buf) || !is_listed
            continue
        endif
        exec "silent bd" bufnr
    endfor
endfunc
function! s:save_old_session()
    if exists('g:this_obsession') && get(g:, 'obsession_no_bufenter', v:false)
        call s:mksession(g:this_obsession)
    endif
endfunction
function! s:should_load_session(session)
    if !filereadable(a:session)
        let def = "no"
    else
        let def = "yes"
    endif
    let state = session_utils#state_of_session(a:session)
    if state == "synchronized"
        let answer = confirm('Session is already active:', "&Pause\n&Save") 
        if answer == 1
            return "pause"
        else
            return "no"
        endif
    elseif state == "paused"
        let answer = confirm('Session is paused:', "&Load from file\n&Resume\n&Cancel") 
        if answer == 1
            return def
        elseif answer == 2
            return "no"
        else
            return "abort"
        endif
    endif
    return def
endfunction
function! session_utils#delete_session(session)
    let session = fnameescape(a:session)
    if session_utils#current_session() == session
        call s:pause_obsession()
    endif
    if filewritable(session)
        call delete(fnameescape(session))
    endif
endfunction
function! session_utils#state_of_session(session)
    if exists('g:this_obsession') && g:this_obsession == a:session
        return 'synchronized'
    endif
    if v:this_session == a:session
        return 'paused'
    endif
    return 'none'
endfunction
function! session_utils#current_session()
    return get(g:, 'this_obsession', v:this_session)
endfunction

function! s:pause_obsession()
    if exists('g:this_obsession')
        unlet g:this_obsession
    endif
endfunc
function! s:load_session(session_name)
    try
        " call s:mutate_session(a:session_name)
        exec "source " . a:session_name
    catch
        echom "Error in session: " . v:errmsg
        call getchar()
    endtry
endfunc
function! s:mksession(session_name)
    exec "mksession! " . a:session_name
    let v:this_session = a:session_name
endfunction
function! s:unpause_obsession(session_name)
    let g:this_obsession = a:session_name
    let v:this_session = a:session_name
endfunction
function! s:mutate_session(session_name)
    if !exists('g:session#save_terminals') || 'g:session#save_terminals'
        return
    endif
    let lines = readfile(a:session_name)
    let command = "substitute(v:val, '". 'badd .* term:\/\/.*' . "', '\" terminal load deleted by fzf-session.vim', 'g')"
    call map(lines, command)
    call writefile(lines, a:session_name)
endfunction
