class test_base;
    
    virtual data_aligner_intf_in vif_in;
    virtual data_aligner_intf_out vif_out;

    data_align_cfg cfg;

    env_base env;

    mailbox#(packet_in) gen2drv;
    mailbox#(packet_in) in_mbx;
    mailbox#(packet_out) out_mbx;

    function  new(
        virtual data_aligner_intf_in vif_in,
        virtual data_aligner_intf_out vif_out, 
        data_align_cfg cfg
    );
        this.vif_in = vif_in; // получение интерфейсов
        this.vif_out = vif_out;
        this.cfg = cfg;

        // создание экземпляров классов
        env = new();
        gen2drv = new();
        in_mbx = new();
        out_mbx = new();
        // конфигурация (рандомизация количества пакетов и интенсивности)
        if( !cfg.randomize() ) begin
            $error("Can't randomize test configuration!");
            $finish();
        end
        // пробрасываем конфигурацию
        env.master.master_gen.cfg          = cfg;
        env.master.master_driver.cfg       = cfg;
        env.check.cfg                      = cfg;
        // пробрасываем почтовые ящики
        env.master.master_gen.gen2drv      = gen2drv;
        env.master.master_driver.gen2drv   = gen2drv;
        env.master.master_monitor.in_mbx   = in_mbx;
        env.slave.slave_monitor.out_mbx    = out_mbx;
        env.check.in_mbx                   = in_mbx;
        env.check.out_mbx                  = out_mbx;
        // пробрасываем интерфейсы
        env.master.master_driver.vif_in    = vif_in;
        env.master.master_monitor.vif_in   = vif_in;
        env.slave.slave_monitor.vif_out    = vif_out;
    endfunction

    virtual task run();
        bit done;
        fork
            env.run();
            reset_checker();
            timeout();
        join_none   
        wait(env.check.done);
        $display("Test was finished!");

        $finish();
    endtask

    virtual task reset_checker();
        forever begin
            wait(~vif_in.aresetn);
            env.check.in_reset = 1;
            wait(vif_in.aresetn);
            env.check.in_reset = 0;
        end
    endtask

    task timeout();
        repeat(cfg.test_timeout_cycles) @(posedge vif_in.clk);
        $error("Test timeout!");
        $finish();
    endtask

endclass