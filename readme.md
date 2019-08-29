Simple session loader that works with fzf. Sessions are stored in ~/.vim/sessions .

![Screenshot](screenshot.png)

- Enter on [New session] creates a new session
- Enter selects an existing session. This unloads all buffers of the current session and loads the new one
- Ctrl-d deletes all selected session files.

If you want to run this in your vimrc on startup you need some slight trickery:

    if (!exists('g:first_load'))
        if v:vim_did_enter
          SessionLoad
        else
         au VimEnter * SessionLoad
        endif
    endif
    let g:first_load = v:false


## Installation:

With vim-plug:

    Plug 'Tarmean/fzf-session.vim'
    Plug 'tpope/vim-obsession'
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install' }
    let g:obsession_no_bufenter = 1

The plugin works perfectly fine without vim-obsession but you won't automatically store the session when quitting vim.

## Note:

Whe using SessionLoad to switch we

- unload all current buffers
- unload all buffers 

If you have any unsaved buffers, including terminals, they are left loaded.

Terminal buffers can't be restored in a real way - instead we just reopen the program they were started with. Leaving all existing terminals open and reloading all old ones causes exponential terminal buffers when switching between sessions repeatedly.

As a band aid fix we change sessions to not save terminal buffers. You can disable this with:

    let g:session#save_terminals = v:true
