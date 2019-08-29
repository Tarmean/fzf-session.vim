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
- close all windows 
- wipe all terminals

If you have any unsaved buffers this pauses with the unsaved buffers loaded. Save or bd! the unsaved buffers and repeat your action.

The unloaded state is restored when reloading our old session. However we only get new terminal buffers instead of restoring whatever was running in them.

If you want to keep terminal buffers open when switching sessions use

    let g:session#unload_old_sessions = 0

vim will still save empty terminal buffers into session files, though, so this will create increase the amount of open terminal buffers with each session switch.
