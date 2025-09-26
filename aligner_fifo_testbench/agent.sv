class master_data_aligner_agent_base;
    
    master_data_aligner_gen_base master_gen;
    master_data_aligner_monitor_base master_monitor;
    master_data_aligner_driver_base master_driver;

    function new();
        master_gen     = new();
        master_monitor = new();
        master_driver  = new();
    endfunction

    virtual task run();
        fork
            master_gen    .run();
            master_monitor.run();
            master_driver .run();
        join
    endtask

endclass

class slave_data_aligner_agent_base;
    
    slave_data_aligner_monitor_base slave_monitor;

    function new();
        slave_monitor = new();
    endfunction

    virtual task run();
        fork
            slave_monitor.run();
        join
    endtask
endclass