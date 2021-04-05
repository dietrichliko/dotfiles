
if [[ $TERM != "linux" ]]; then

  if [ -z "${SINGULARITY_NAME}" ]; then
      export SINGULARITY_NAME=""
  fi

  POWERLINE_OPTS="\
    -max-width 50 \
    -theme default \
    -hostname-only-if-ssh \
    -path-aliases /eos/vbc/user/dietrich.liko=EOS,/eos/vbc/experiments/cms/store=STORE,/scratch-cbe/users/dietrich.liko=SCRATCH \
    -duration-min 10 \
    -cwd-max-dir-size 8 \
    -static-prompt-indicator \
    -shell-var SINGULARITY_NAME \
    -shell-var-no-warn-empty \
    -modules host,venv,shell-var,cwd,perms,git,duration,exit"

  POWERLINE_CMD=$HOME/.local/libexec/powerline-go

  # until bash 4.4
  INTERACTIVE_BASHPID_TIMER="/tmp/${USER}.START.$$"
  PS0='$(echo $SECONDS > "$INTERACTIVE_BASHPID_TIMER")'

  function powerline_ps1() {
      local error=$?
      local duration=0
      if [ -e ${INTERACTIVE_BASHPID_TIMER} ]; then
	  local end=$SECONDS
          local start
	  read start < ${INTERACTIVE_BASHPID_TIMER}
	  duration=$((${end} - ${start:-$end}))
	  rm ${INTERACTIVE_BASHPID_TIMER}
      fi
      set -- ${POWERLINE_OPTS}
#      echo ${POWERLINE_CMD} $@ -error $? -duration $duration
      PS1="$(${POWERLINE_CMD} $@ -error $? -duration $duration)"
  }

  PROMPT_COMMAND="powerline_ps1; $PROMPT_COMMAND"

fi
