class data_align_cfg;
    rand int pkt_amount          = 100     ; // количество пакетов
    rand int write_intense       = 70      ; // интенсивность записи в FIFO, %
    rand int flag_fifo_full      = 1       ; // флаг для переполения очереди, если 1 - переполнена, 0 - не переполняется
         int test_timeout_cycles = 10000000;
         int            DELAY_BW_1ST_2D    ; // пока меняем в testbench.sv
         int            DEPTH_FIFO         ; // пока меняем в testbench.sv    
         logic [31:0]   DEFAULT_ELEMENT_2D ; // пока меняем в testbench.sv
        //  logic [31:0]   ELEMENT_TYPE_1ST   ;      // типы
        //  logic [31:0]   ELEMENT_TYPE_2D    ;
    
    
    constraint pkt_amount_c {          // ограничение на количество пакетов
        pkt_amount inside {[100:500]};
    }

    constraint write_intense_c {
        write_intense inside {[0:100]};
    }

    constraint flag_fifo_full_c {
        flag_fifo_full inside {[0:1]};
    }

  function void post_randomize();
    string str;
    str = {str, $sformatf("\nConfiguration:\n")};
    if (flag_fifo_full) str = {str, $sformatf("FIFO is overflowing\n")};
    else                str = {str, $sformatf("FIFO is NOT overflowing\n")};
    str = {str, $sformatf("pkt_amount  : %0d\n"               , pkt_amount          )};
    str = {str, $sformatf("FIFO data write intensity: %0d\n"  , write_intense       )};
    str = {str, $sformatf("test_timeout_cycles: %0d\n"        ,  test_timeout_cycles)};
    $display(str);
  endfunction
    
endclass