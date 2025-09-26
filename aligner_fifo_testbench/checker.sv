class checker_data_aligner_base;

    data_align_cfg cfg;

    mailbox#(packet_out) out_mbx;
    mailbox#(packet_in_1) in_mbx_1;
    mailbox#(packet_in_2) in_mbx_2;

    bit done;
    int cnt;

    virtual task run();
        packet_in_1 tmp_p1;
        packet_in_2 tmp_p2;
        forever begin
            wait(~vif_in.aresetn);
            fork
                do_check();
                wait(vif_in.aresetn)
            join_any
            disable fork;
            if(done) break;
            while (in_mbx_1.try_get(tmp_p1) & in_mbx_2.try_get(tmp_p2)) cnt++;
        end
    endtask

    virtual task do_check();
        packet_in_1 = p_in1;
        packet_in_2 = p_in2;
        packet_out  = p_out;

        forever begin
            in_mbx_1. 
        end
    endtask
    
endclass