class master_data_aligner_driver_base;
    
    virtual data_aligner_intf_in vif_in;

    data_align_cfg cfg;

    mailbox#(packet_in) gen2drv;


    virtual task run(); 
        forever begin
            @(posedge vif_in.clk);
            fork
               forever begin
                    drive_loop();
                end 
            join_none
                
            wait(~vif_in.aresetn);
            disable fork;
            reset_master();
            wait(vif_in.aresetn);
        end
    endtask
    

    virtual task reset_master();
        vif_in.vld_1st_i <= 0;
        vif_in.vld_2d_i <= 0;
        vif_in.data_1st_i <= cfg.DEFAULT_ELEMENT_2D;
        vif_in.data_2d_i <= cfg.DEFAULT_ELEMENT_2D;
    endtask


    virtual task drive_loop();
        packet_in p_in;
        @(posedge vif_in.clk);
        if ($urandom_range(0,99) < cfg.write_intense) begin
            // получаем новые пакеты
            gen2drv.get(p_in);
            drive_master(p_in);
        end else begin
            vif_in.vld_1st_i <= 0;  
            vif_in.vld_2d_i <= 0;
        end
            
    endtask


    virtual task drive_master(packet_in p_in);
        vif_in.data_1st_i <= p_in.data_1st_i;
        vif_in.vld_1st_i <= 1;
    fork
        begin
            // перед подачей data_2d_i
            // мы должны выждать задержку в DELAY_BW_1ST_2D тактов
            // + проверка на переполнение FIFO
            //  (если флаг переполнения = 1, то мы делаем доп задержку в 1 такт для выдачи данных)
            repeat(cfg.DELAY_BW_1ST_2D + cfg.flag_fifo_full)  @(posedge vif_in.clk);
            vif_in.data_2d_i <= p_in.data_2d_i;
            vif_in.vld_2d_i <= 1;
            @(posedge vif_in.clk);
            vif_in.vld_2d_i <= 0;
            vif_in.data_2d_i <= cfg.DEFAULT_ELEMENT_2D;
        end
    join_none
        @(posedge vif_in.clk);
        vif_in.vld_1st_i <= 0;
        vif_in.data_1st_i <= cfg.DEFAULT_ELEMENT_2D;

    endtask



endclass