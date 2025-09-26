class master_data_aligner_driver_base;
    
    virtual data_aligner_intf_in vif_in;

    data_align_cfg cfg;

    mailbox#(packet_in_1) gen2drv1;
    mailbox#(packet_in_2) gen2drv2;

    bit driver_enabled = 0;


    virtual task run(); 
        forever begin
            @(posedge vif_in.clk);
            driver_enabled = 1;
            fork
               forever begin
                    drive_loop();
                end 
            join_none
                
            wait(~vif_in.aresetn);
            driver_enabled = 0;
            disable fork;
            reset_master();
            wait(vif_in.aresetn);
        end
    endtask
    

    virtual task reset_master();
        vif_in.vld_1st_i <= 0;
        vif_in.vld_2d_i <= 0;
        vif_in.data_1st_i <= cfg.DEFAULT_ELEMENT_1ST;
        vif_in.data_2d_i <= cfg.DEFAULT_ELEMENT_2D;
    endtask


    virtual task drive_loop();
        packet_in_1 p_in1;
        packet_in_2 p_in2;
        while (driver_enabled) begin
            @(posedge vif_in.clk);
            if ($urandom_range(0,99) < cfg.write_intense) begin
                // получаем новые пакеты
                gen2drv1.get(p_in1);
                gen2drv2.get(p_in2);
                drive_master(p_in1, p_in2);
            end else begin
                vif_in.vld_1st_i <= 0;
                vif_in.vld_2d_i <= 0;
            end
        end
        
    endtask



    virtual task drive_master(packet_in_1 p_in1, packet_in_2 p_in2);
        vif_in.data_1st_i <= p_in1.data_1st_i;
        vif_in.vld_1st_i <= 1;
    fork
        begin
            // перед подачей data_2d_i
            // мы должны выждать задержку в DELAY_BW_1ST_2D тактов
            repeat(cfg.DELAY_BW_1ST_2D)  @(posedge vif_in.clk);
            vif_in.data_2d_i <= p_in2.data_2d_i;
            vif_in.vld_2d_i <= 1;
            @(posedge vif_in.clk);
            vif_in.data_2d_i <= cfg.DEFAULT_ELEMENT_2D;
            vif_in.vld_2d_i <= 0;
        end
    join_none
        @(posedge vif_in.clk);
        vif_in.data_1st_i <= cfg.DEFAULT_ELEMENT_1ST;
        vif_in.vld_1st_i <= 0;

    endtask



endclass