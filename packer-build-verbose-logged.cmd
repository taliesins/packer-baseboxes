set PACKER_LOG=1
set PACKER_LOG_PATH=%1.log.txt
call packer build %1
