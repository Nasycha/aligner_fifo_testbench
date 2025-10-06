class master_data_aligner_monitor_base;

    virtual data_aligner_intf_in vif_in;

    mailbox#(packet_in) in_mbx;

    virtual task run();
        forever begin
            wait(vif_in.aresetn);
            fork
                forever begin
                    monitor_master();
                end
            join_none
            wait(~vif_in.aresetn);
            disable fork;
        end
    endtask

    

    virtual task monitor_master();
        packet_in p_in;

        forever begin
            @(posedge vif_in.clk);
            if (vif_in.vld_1st_i && vif_in.vld_2d_i) begin
                p_in = new();
                p_in.data_1st_i = vif_in.data_1st_i;
                p_in.data_2d_i  = vif_in.data_2d_i ;
                // флаг валидности
                p_in.valid_1st_i = vif_in.vld_1st_i;
                p_in.valid_2d_i = vif_in.vld_2d_i;
                in_mbx.put(p_in);
            end
            else if (vif_in.vld_1st_i || vif_in.vld_2d_i) begin
                p_in = new();
                if (vif_in.vld_1st_i) begin
                    p_in.data_1st_i = vif_in.data_1st_i;
                    p_in.data_2d_i  = '0;
                    // флаг валидности
                    p_in.valid_1st_i = vif_in.vld_1st_i;
                    p_in.valid_2d_i = 0;
                    in_mbx.put(p_in);
                end
                if (vif_in.vld_2d_i) begin
                    p_in.data_2d_i = vif_in.data_2d_i;
                    p_in.data_1st_i = '0;
                    // флаг валидности 
                    p_in.valid_2d_i = vif_in.vld_2d_i;
                    p_in.valid_1st_i = 0;
                    in_mbx.put(p_in);
                end
            end
        end
    endtask
endclass

class slave_data_aligner_monitor_base;

    virtual data_aligner_intf_out vif_out;

    mailbox#(packet_out) out_mbx;

    virtual task run();
        forever begin
            wait(vif_out.aresetn);
            fork
                forever begin
                    monitor_slave();
                end
            join_none
            wait(~vif_out.aresetn);
            disable fork;
        end
    endtask

    virtual task monitor_slave();
        packet_out p_out;
        forever begin
            @(posedge vif_out.clk);
            if (vif_out.vld_o) begin
                p_out = new();
                p_out.data_1st_o = vif_out.data_1st_o;
                p_out.data_2d_o  = vif_out.data_2d_o ;
                p_out.statuses_o = vif_out.statuses_o;
                out_mbx.put(p_out);
            end
        end
    endtask
endclass