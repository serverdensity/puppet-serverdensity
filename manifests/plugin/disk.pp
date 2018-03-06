# == Class: serverdensity_agent::plugin::disk
#
# Defines Disk plugin configuration
#
# === Parameters
#
# [*use_mount*]
#   Boolean. Use mount points to collect disk and fs metrics instead of volumes
#   Values should be set to either 'yes' or 'no'
#   Default: no
#
# [*excluded_filesystems*]
#   String/Array. The filesystems to be excluded from the check
#   Default: undef
#
# [*excluded_disks*]
#   String/Array The disks to be excluded from the check
#   Default: undef
#
# [*excluded_disk_re*]
#   String. Regex to excude disks.
#   Default: undef
#
# [*excluded_mountpoint_re*]
#   String. Regex to excude mountpoints.
#   Default: undef
#
# [*all_partitions*]
#   Boolean. Instructs agent to collect metrics for all partitions
#   user_mount must be enabled for this option
#   Default: undef
#
# [*tag_by_filesystem*]
#   Boolean. Have the check tag disk metrics with their filesystem
#   Values should be set to either 'yes' or 'no'
#   Default: undef
#
# === Examples
#
# class { 'serverdensity_agent::plugin::disk':
#    use_mount              => 'no',
#    excluded_filesystems   => ['tmpfs', 'run'],
#    excluded_disks         => ['/dev/sda', '/dev/sdb'],
#    excluded_disk_re       => '/dev/sda.*',
#    excluded_mountpoint_re => '/mnt/no-monitor.*',
#    all_partitions         => false,
#    tag_by_filesystem      => 'yes'
# }
#
class serverdensity_agent::plugin::disk (
    $use_mount              = 'no',
    $excluded_filesystems   = undef,
    $excluded_disks         = undef,
    $excluded_disk_re       = undef,
    $excluded_mountpoint_re = undef,
    $all_partitions         = undef,
    $tag_by_filesystem      = undef
  ) {
  serverdensity_agent::plugin { 'disk':
    config_content => template('serverdensity_agent/plugin/disk.yaml.erb'),
  }
}
