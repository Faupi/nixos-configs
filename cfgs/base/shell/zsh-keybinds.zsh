# https://stackoverflow.com/a/30899296

r-delregion() {
  if ((REGION_ACTIVE)) then
     zle kill-region
  else 
    local widget_name=$1
    shift
    zle $widget_name -- $@
  fi
}

r-deselect() {
  ((REGION_ACTIVE = 0))
  local widget_name=$1
  shift
  zle $widget_name -- $@
}

r-select() {
  ((REGION_ACTIVE)) || zle set-mark-command
  local widget_name=$1
  shift
  zle $widget_name -- $@
}

for key     kcap    seq         mode      widget (
    sleft   kLFT    $'\e[1;2D'  select    backward-char
    sright  kRIT    $'\e[1;2C'  select    forward-char
    sup     kri     $'\e[1;2A'  select    up-line-or-history
    sdown   kind    $'\e[1;2B'  select    down-line-or-history

    send    kEND    $'\e[1;2F'  select    end-of-line
    send2   x       $'\e[4;2~'  select    end-of-line

    shome   kHOM    $'\e[1;2H'  select    beginning-of-line
    shome2  x       $'\e[1;2~'  select    beginning-of-line

    left    kcub1   $'\eOD'     deselect  backward-char
    right   kcuf1   $'\eOC'     deselect  forward-char

    end     kend    $'\eOF'     deselect  end-of-line
    end2    x       $'\e4~'     deselect  end-of-line

    home    khome   $'\eOH'     deselect  beginning-of-line
    home2   x       $'\e1~'     deselect  beginning-of-line

    csleft  x       $'\e[1;6D'  select    backward-word
    csright x       $'\e[1;6C'  select    forward-word
    csend   x       $'\e[1;6F'  select    end-of-line
    cshome  x       $'\e[1;6H'  select    beginning-of-line

    cleft   x       $'\e[1;5D'  deselect  backward-word
    cright  x       $'\e[1;5C'  deselect  forward-word

    del     kdch1   $'\e[3~'    delregion delete-char
    bs      x       $'^?'       delregion backward-delete-char
    cbs     x       $'^H'       deselect  backward-delete-word

    stab    x       $'\e[Z'     deselect  autosuggest-accept
) {

  local name="key-$key"

  # Create wrapper function
  eval "$name() {
    r-$mode $widget \$@
  }"

  # Create widget
  zle -N $name

  # Bind key
  bindkey ${terminfo[$kcap]-$seq} $name

  # Fix for autosuggest accepting
  if [[ $mode = "deselect" ]]; then
    if [[ $widget = "autosuggest-accept" || $ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[(Ie)$widget] -ne 0 ]]; then
      ZSH_AUTOSUGGEST_ACCEPT_WIDGETS+=( $name )
    fi
  fi

  # TODO: Create a better general wrapping method that retains widget names for deselect commands

}
