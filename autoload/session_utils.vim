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
    endtry
endfunction
function! session_utils#load_session(session)
    call s:unload_session()
    try
        call s:load_session(a:session)
    endtry
endfunc
function! s:unload_session()
    bufdo! bd
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
    return !(session_utils#current_session() == a:session)
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
