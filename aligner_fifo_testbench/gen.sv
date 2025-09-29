class master_data_aligner_gen_base;
    
    data_align_cfg cfg;

    mailbox#(packet_in) gen2drv;

    virtual task run();
        repeat(cfg.pkt_amount) begin
            gen_master();
        end
    endtask

    virtual task gen_master();
        packet_in p_in;
        p_in = create_packet();
        if (!p_in.randomize() with {
        }) begin
            $error("Can't randomize packet!");
            $finish();
        end
        gen2drv.put(p_in);
    endtask
    
    
    virtual function packet create_packet();
        packet_in p_in;
        p_in = new();
        return p_in;
    endfunction

endclass