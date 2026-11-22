# ~/.config/shell/funcs.sh — shell functions for zsh and bash
# Managed by chezmoi. Sourced from ~/.zshrc and ~/.bashrc.

# showpath [VAR] — print a colon-separated variable, one entry per line
showpath() {
    local _var=${1:-PATH} _val
    eval "_val=\${$_var-}"
    echo "$_var="
    [ -n "$_val" ] && printf '%s\n' "$_val" | tr ':' '\n' | sed 's/^/    /'
    return 0
}
path()      { showpath PATH; }
pypath()    { showpath PYTHONPATH; }
py27path()  { showpath PYTHON27PATH; }
py3path()   { showpath PYTHON3PATH; }
ldpath()    { showpath LD_LIBRARY_PATH; }
cmakepath() { showpath CMAKE_MODULE_PATH; }

# CERN / CMS environments from CVMFS
lcg-view-setup() {
    . /cvmfs/sft.cern.ch/lcg/views/setupViews.sh "${1:-LCG_101}" "${2:-x86_64-centos7-gcc11-opt}"
}
rucio-setup() { . /cvmfs/cms.cern.ch/rucio/setup-py3.sh; }
crab-setup()  { . /cvmfs/cms.cern.ch/crab3/crab.sh; }
