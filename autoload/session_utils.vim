if !exists('g:session#unload_old_sessions')
    let g:session#unload_old_sessions = v:true
endif
if !exists('g:session#wipe_terminals')
    let g:session#wipe_terminals = v:true
endif
function! session_utils#synchronize_session(session)
    let session = fnameescape(a:session)
    call s:save_old_session()
    call s:pause_obsession()
    try
        if s:should_load_session(session)
            call session_utils#load_session(session)
        endif
        call s:mksession(session)
        call s:unpause_obsession(session)
    catch
        echom v:errmsg
        call getchar()
    endtry
endfunction
function! session_utils#load_session(session)
    call s:unload_session()
    try
        call s:load_session(a:session)
    catch
        echom v:errmsg
        call getchar()
    endtry
endfunc
function! s:unload_session()
    if !g:session#unload_old_sessions
        return
    endif
    for b in getbufinfo()
        if !b.loaded
            continue
        endif
        if b.name !~# '^term://'
            exec b.bufnr . " bd"
        elseif g:session#wipe_terminals
            exec b.bufnr . "bufdo bd!"
        endif
    endfor
endfunc
function! s:save_old_session()
    if exists('g:this_obsession') && get(g:, 'obsession_no_bufenter', v:false)
        call s:mksession(g:this_obsession)
    endif
endfunction
function! s:should_load_session(session)
    if !filereadable(a:session)
        return v:false
    endif
    let state = session_utils#state_of_session(a:session)
    if state == "synchronized"
        return v:false
    elseif state == "paused"
        return  input('Reload session from file? y/n: ') =~? 'y\%[es]'
    else
        return v:true
    endif
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
        exec "source " . a:session_name
    catch
        echom "Error in session: " . v:errmsg
        call getchar()
    endtry
endfunc
function! s:mksession(session_name)
    exec "mksession! " . fnameescape(a:session_name)
    let v:this_session = a:session_name
endfunction
function! s:unpause_obsession(session_name)
    let g:this_obsession = a:session_name
    let v:this_session = a:session_name
endfunction
