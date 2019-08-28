Simple session loader that works with fzf. Sessions are stored in ~/.vim/sessions .

Enter selects a session which unloads the current session and loads the new one. Ctrl-d deletes all selected session files.


If you want to run this in your vimrc you need slight trickery:


    if (!exists('g:first_load'))
        call feedkeys(":SessionLoad\n", 'n')
    endif
    let g:first_load = v:false
