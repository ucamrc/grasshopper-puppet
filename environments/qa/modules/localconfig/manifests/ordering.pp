class localconfig::ordering {

    ## All these components should be installed before Grasshopper
    Class['::ghservice::postgresql']    -> Class['::grasshopper']
    Class['::ghservice::apache']        -> Class['::grasshopper']
    Class['::ghservice::ui']            -> Class['::grasshopper']
}
