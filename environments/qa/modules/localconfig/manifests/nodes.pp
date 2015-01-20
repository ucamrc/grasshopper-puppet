node 'qa0' {
    $nodetype = 'qa'
    $nodesuffix = 0
    hiera_include(classes)
}

node 'puppet' {
    $nodetype = 'puppet'
    hiera_include(classes)
}
