class data_align_cfg;
    rand int pkt_amount               = 100; // кол-во пакетов
         int write_intense            = 100; // интенсивности количества подаваемых данных  
         int DELAY_BW_1ST_2D          = 4;
         int WIDTH_FIFO               = 32;
         int DEPTH_FIFO               = 4;
         logic [31:0]   DEFAULT_ELEMENT_1ST = 32'b0;           // инициализация
         logic [31:0]   DEFAULT_ELEMENT_2D = 32'b0;

  
         int test_timeout_cycles = 10000000;
    
    
    constraint pkt_amount_c {          // ограничение на количество пакетов
        pkt_amount inside {[100:500]}; // ?
    }

    constraint write_intense_c {
        write_intense inside {[0:100]};
    }

    constraint read_intense_c {
        read_intense inside {[0:100]};
    }   
    
  function void post_randomize();
    DEPTH_FIFO = DELAY_BW_1ST_2D;

    string str;
    str = {str, $sformatf("pkt_amount  : %0d\n"               , pkt_amount          )};
    str = {str, $sformatf("FIFO data write intensity: %0d\n"  , write_intense       )};
    str = {str, $sformatf("FIFO data reading intensity: %0d\n",  read_intense       )};
    str = {str, $sformatf("test_timeout_cycles: %0d\n"        ,  test_timeout_cycles)};
    $display(str);
  endfunction
    
endclass