class master_data_aligner_monitor_base;

    virtual data_aligner_intf_in vif_in;

    mailbox#(packet_in_1) in_mbx_1;
    mailbox#(packet_in_2) in_mbx_2;

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
        packet_in_1 p_in1;
        packet_in_2 p_in2;

        forever begin
            @(posedge vif_in.clk);
            if (vif_in.vld_1st_i) begin
                p_in1 = new();
                p_in1.data_1st_i = vif_in.data_1st_i;
                in_mbx_1.put(p_in1);
            end
            if (vif_in.vld_2d_i) begin
                p_in2 = new();
                p_in2.data_2d_i = vif_in.data_2d_i;
                in_mbx_2.put(p_in2);
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

    virtual task monitor_slave(port_list);
        packet_out p_out;
        forever begin
            @(posedge vif_out.clk);
            if (vif_out.vld_o) begin
                p_out = new();
                p_out.data_1st_o = vif_out.data_1st_o;
                p_out.data_2d_o  = vif_out.data_2d_o ;
                p_out.vld_o      = vif_out.vld_o     ;
                p_out.statuses_o = vif_out.statuses_o;
                out_mbx.put(p_out);
            end
        end
    endtask
endclass