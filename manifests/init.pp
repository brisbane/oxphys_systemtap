class systemtap (
   $exename = "/usr/bin/staprun",
   $options = "-D -o /var/log/staprun",
   $stopoptions = "-d jobio",
   $conf = "/etc/staprun.conf",
   $prog = "staprun",
   $staprunservicestate = "running",
) {
    ensure_packages [ systemtap ]
    $prognm = $systemtap::prog
    $opts="$options /root/jobio/${kernelrelease}/jobio.ko"
    $stopopts = "-d jobio"

#get system ready with stap-prep
#Generate debug with stap -t -d  --suppress-handler-errors  -DTRYLOCKDELAY=1000 -DMAXTRYLOCK=10 -DMAXMAPENTRIES=16384 -DMAXACTION=8192  /home/brisbane/bin/admin-scripts/jobio.stap  -m jobio.ko
#Generate proper with stap  --suppress-handler-errors  -DTRYLOCKDELAY=1000 -DMAXTRYLOCK=10 -DMAXMAPENTRIES=16384 -DMAXACTION=8192  /home/brisbane/bin/admin-scripts/jobio.stap  -m jobio.ko

     file { '/root/jobio' :
       source => "puppet:///modules/$module_name/jobio/",
       ensure => directory, # so make this a directory
       recurse => true, # enable recursive directory management
       purge => true, # purge all unmanaged junk
       force => true, # also purge subdirs and links etc.
       owner => "root",
       group => "root",
       mode => 0644, # this mode will also apply to files from the source directory
       notify => Service["$prognm"]
     }
     file {"/etc/init.d/$prognm":
         content => template("$module_name/initscript.erb"),
         mode => '0755',
         notify => Service["$prognm"]
     }
     service {"$prognm":
        ensure => $staprunservicestate,
        enable => true,
        require => [File['/root/jobio'], File["/etc/init.d/$prognm"]]
     }

}
