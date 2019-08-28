Simple session loader that works with fzf. Sessions are stored in ~/.vim/sessions .

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