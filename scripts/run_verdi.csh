#!/bin/csh -f
setenv LM_LICENSE_FILE `getLf novas`
setenv VERDI_HOME `ToolConfig.pl get_tool_path verdi`
setenv VCS_HOME `ToolConfig.pl get_tool_path vcs`

if ($# <= 1) then
  echo "Usage: $0 <model> <dut> [fsdb_file]"
  echo "ERROR! Incorrect # of arguments specified. "
endif

if ($# == 2) then
  if (-f $MODEL_ROOT/target/$1/vcs_4value/$2/$2.simv) then
     $VERDI_HOME/bin/verdi -ssy -lps_off -nologo -simBin $MODEL_ROOT/target/$1/vcs_4value/$2/$2.simv -simflow
  else
     echo "Usage: $0 <model> <dut> [fsdb_file]"
     echo "ERROR!  $MODEL_ROOT/target/$1/vcs_4value/$2/$2.simv does not exist!"
  endif
endif

if ($# == 3) then
  if (-f $3) then
     $VERDI_HOME/bin/verdi -ssy -lps_off -nologo -simBin $MODEL_ROOT/target/$1/vcs_4value/$2/$2.simv -simflow -ssf $3
  else
     echo "Usage: $0 <model> <dut> [fsdb_file]"
     echo "ERROR!  fsdb file: $2 does not exist."
  endif
endif

