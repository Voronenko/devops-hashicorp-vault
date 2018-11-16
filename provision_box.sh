# Static parameters
WORKSPACE=./
BOX_PLAYBOOK=$WORKSPACE/box.yml
BOX_NAME=demovault
BOX_ADDRESS=34.241.249.98
BOX_USER=ubuntu
BOX_PWD=

prudentia ssh <<EOF
unregister $BOX_NAME

register
$BOX_PLAYBOOK
$BOX_NAME
$BOX_ADDRESS
$BOX_USER
$BOX_PWD

verbose 1
set box_address $BOX_ADDRESS

provision $BOX_NAME
EOF
