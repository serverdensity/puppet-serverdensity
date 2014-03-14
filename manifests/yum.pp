class serverdensity::yum {
  $repo_baseurl = 'http://www.serverdensity.com/downloads/linux/redhat/'
  $repo_keyurl = 'https://www.serverdensity.com/downloads/boxedice-public.key'

  yumrepo { 'serverdensity':
    baseurl  => $repo_baseurl,
    gpgkey   => $repo_keyurl,
    descr    => "Server Density",
    enabled  => 1,
    gpgcheck => 1,
  }
  # install SD agent package
  package { 'sd-agent':
    ensure   => present,
    require  => Yumrepo['serverdensity']
  }
}
