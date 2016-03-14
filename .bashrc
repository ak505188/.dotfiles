alias gs="git status"
alias gc="git commit -m"
alias gp="git push -u origin"

function parse_git_branch {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

export PS1="\d \A \u@\h:(\w)\$ \$(parse_git_branch) "
