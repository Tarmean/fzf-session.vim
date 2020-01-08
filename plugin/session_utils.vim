command! -bang     SessionLoad                   call session#session('<bang>')
command! -bang     SessionUnload                   call session_utils#empty_session('<bang>')

