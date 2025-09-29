class checker_data_aligner_base;

    data_align_cfg cfg;

    mailbox#(packet_out) out_mbx;
    mailbox#(packet_in) in_mbx;

    bit done;
    int cnt;

    virtual task run();
        packet_in tmp_p;
        forever begin
            wait(~vif_in.aresetn);
            fork
                do_check();
                wait(vif_in.aresetn)
            join_any
            disable fork;
            if(done) break;
            while (in_mbx.try_get(tmp_p)) cnt++;
        end
    endtask

    virtual task do_check();
        packet_in = p_in;
        packet_out  = p_out;

        // forever begin
        //     in_mbx.try_get(tmp_p);
        // end
    endtask
    
endclass