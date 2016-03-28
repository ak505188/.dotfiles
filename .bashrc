alias gs="git status"
alias gc="git commit -m"
alias gp="git push -u origin"
alias ls="ls -G"

function parse_git_branch {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}

# Import colors from bash_colors
[[ -f ~/.bash_colors ]] && . ~/.bash_colors


PS1="\[${Green}\]\u@\h \[${Purple}\]\w \[${BRed}\]\$(parse_git_branch)\[${Reset}\]$ "
