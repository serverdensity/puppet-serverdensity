class puppet-serverdensity( $content ) {
    
    file { 'test':
        path => '/tmp/test_file',
        content => $content
    }
}