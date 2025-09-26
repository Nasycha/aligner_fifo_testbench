class master_data_aligner_gen_base;
    
    data_align_cfg cfg;

    mailbox#(packet_in) gen2drv;

    virtual task run();
        repeat(cfg.pkt_amount) begin
            gen_master();
        end
    endtask

    virtual task gen_master();
        fork
            gn_for_pkt_1();
            gn_for_pkt_2();
        join
    endtask
    
    virtual task gn_for_pkt_1();
        packet_in_1 p_in1;
        p_in1 = create_packet1();
        if (!p_in1.randomize()) begin
            $error("Can't randomize packet!");
            $finish();
        end
        gen2drv.put(p_in1);
    endtask

    virtual task gn_for_pkt_2();
        packet_in_2 p_in2;
        p_in2 = create_packet2();
        if (!p_in2.randomize()) begin
            $error("Can't randomize packet!");
            $finish();
        end
        gen2drv.put(p_in2);
    endtask
    
    
    virtual function packet create_packet1();
        packet_in_1 p_in1;
        p_in1 = new();
        return p_in1;
    endfunction

    virtual function packet create_packet2();
        packet_in_2 p_in2;
        p_in2 = new();
        return p_in2;
    endfunction

endclass