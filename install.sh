#!/bin/bash
# This is the install script prior to chroot

# Create a temporary file and make sure it goes away when we're dome
tmp_file=$(tempfile 2>/dev/null) || tmp_file=/tmp/test$$
trap "rm -f $tmp_file" 0 1 2 5 15

# Set up some internally used variables
DIALOG_NEXT=0
DIALOG_PREV=3
DIALOG_CANCEL=1
# Root disk device
#ROOT_DISK=
# Root partition device
#ROOT_DEV=
next_state='begin'

HEIGHT=20
WIDTH=40

begin()
{
  dialog --ok-label "Next" --extra-button --extra-label "Cancel" \
    --msgbox "Welcome to AethOS installation." $HEIGHT $WIDTH

  return_value=$?
  case $return_value in
    $DIALOG_NEXT)
      next_state='find_disk';;
    *)
      next_state='done';;
  esac
}

find_disk()
{
  # Determine which disk to use as root
  dialog --ok-label "Next" --extra-button --extra-label "Back" \
    --menu "Choose an installation disk" $HEIGHT $WIDTH 10 \
    `lsblk -d -n -o KNAME,SIZE` 2>$tmp_file

  return_value=$?

  case $return_value in
    $DIALOG_NEXT)
      # Make sure a disk was chosen
      if [ -s $tmp_file ]; then
        ROOT_DISK='/dev/'`cat $tmp_file`
        next_state='create_partition'
      else
        next_state='find_disk'
      fi
      ;;
    $DIALOG_PREV)
      next_state='begin';;
    *)
      next_state='done';;
  esac
}

create_partition()
{
  #cfdisk $ROOT_DEV
  dialog --ok-label "Next" --extra-button --extra-label "Cancel" \
    --msgbox "TODO create partition on $ROOT_DISK." $HEIGHT $WIDTH

  next_state='find_partition'
}

find_partition()
{
  # Determine which parittion to use as root
  dialog --ok-label "Next" --extra-button --extra-label "Back" \
    --menu "Choose an installation partition" $HEIGHT $WIDTH 10 \
    `lsblk -n -r -f -o NAME,SIZE,TYPE $ROOT_DISK | grep part | sed 's/part//'` 2>$tmp_file

  return_value=$?

  case $return_value in
    $DIALOG_NEXT)
      # Make sure a partition was chosen
      if [ -s $tmp_file ]; then
        ROOT_DEV=/dev/`cat $tmp_file`
        next_state='choose_format_type'
      else
        next_state='find_disk'
      fi
      ;;
    $DIALOG_PREV)
      next_state='find_disk';;
    *)
      next_state='done';;
  esac
}

choose_format_type()
{
  dialog --ok-label "Next" --extra-button --extra-label "Back" \
    --menu "Choose format type" $HEIGHT $WIDTH 10 \
    SKIP "Don't format (use existing format)" \
    ext2  "EXT2 FS" \
    btrfs "BTR FS" \
    2>$tmp_file

  return_value=$?

  case $return_value in
    $DIALOG_NEXT)
      case `cat $tmp_file` in
        SKIP) next_state='start_install';;
        *)    next_state='format_disk'; DISK_FORMAT=`cat $tmp_file`;;
      esac;;
    $DIALOG_PREV)
      next_state='find_partition';;
    *)
      next_state='done';;
  esac
}

format_disk()
{
  dialog \
    --yesno "Are you sure you want to format $ROOT_DEV to format $DISK_FORMAT?" \
    $HEIGHT $WIDTH 2>$tmp_file

  return_value=$?

  case $return_value in
    $DIALOG_NEXT)
      #TODO Do the format
      dialog --ok-label "Next" --extra-button --extra-label "Cancel" \
        --msgbox "Formatting... (not really)" $HEIGHT $WIDTH
      next_state='mount_chroot'
      ;;
    *)
      next_state='format_partition';;
  esac
}

mount_chroot()
{
  ROOT_INSTALL=/mnt/chroot
  mount $ROOT_DEV $ROOT_INSTALL
  cd $ROOT_INSTALL
  tar -xvf /install/rootfs.tar.gz
  chroot $ROOT_INSTALL
  echo "CHROOT applied"
  next_state='done'
}

while true
do
  case $next_state in
    begin)
      begin;;
    find_disk)
      find_disk;;
    create_partition)
      create_partition;;
    find_partition)
      find_partition;;
    choose_format_type)
      choose_format_type;;
    format_disk)
      format_disk;;
    mount_chroot)
      mount_chroot;;
    done)
      clear;
      break;;
  esac
done
