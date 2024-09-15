module router_reg(clock,resetn,pkt_valid,data_in,fifo_full,detect_add,
                  ld_state,laf_state,full_state,lfd_state,rst_int_reg,err,
                  parity_done,low_packet_valid,dout);

input clock,resetn,pkt_valid,fifo_full,detect_add,ld_state,laf_state,full_state,lfd_state,rst_int_reg;
input [7:0]data_in;
output reg err,parity_done,low_packet_valid;
output reg [7:0]dout;
reg [7:0]header,fifo_full_state_byte,int_parity,packet_parity;
  
  
  //DATA OUT LOGIC

 always@(posedge clock)
    begin
      if(!resetn)
       begin
      dout      <=0;
      header    <=0;
      fifo_full_state_byte  <=0;
        end
      else if(detect_add && pkt_valid && data_in[1:0]!=2'b11)
      header<=data_in;
      else if(lfd_state)
      dout<=header;
      else if(ld_state && !fifo_full)
      dout<=data_in;
      else if(ld_state && fifo_full)
      fifo_full_state_byte<=data_in;
      else if(laf_state)
      dout<=fifo_full_state_byte;
  else
    dout<=dout;
     end

  //LOW PACKET VALID LOGIC
 
       always@(posedge clock)
      begin
              if(!resetn)
      low_packet_valid<=0; 
           else if(rst_int_reg)
      low_packet_valid<=0;

              else if(ld_state && !pkt_valid) 
            low_packet_valid<=1;//means header and payload transfer is completed only parity is pending
   end
  //PARITY DONE LOGIC
 
/* always@(posedge clock)
 begin
      if(!resetn)
   parity_done<=0;
     else if(detect_add)
   parity_done<=0;
      else if((ld_state && !fifo_full && !pkt_valid)
              ||(laf_state && low_packet_valid && !parity_done))
   parity_done<=1;
 end*/

//INTERNAL_PARITY CALCULATE LOGIC

 always@(posedge clock)
 begin
      if(!resetn)
  int_parity<=0;
 else if(detect_add)
  int_parity<=0;
 else if(lfd_state && pkt_valid)
  int_parity<=int_parity^header;
 else if(ld_state && pkt_valid && !full_state)
  int_parity<=int_parity^data_in;
 else
  int_parity<=int_parity;
 end
  

//ERROR LOGIC

 always@(posedge clock)
  begin
          if(!resetn)
              err<=0;
          else if(!parity_done)
		  err<=0;
	    
           else if(parity_done)
          begin
               	 if (int_parity==packet_parity)
     		    err<=0;
     		 else 
     		    err<=1;
    	     end
      else
       err<=0;
       end

//PACKET PARITY LOGIC

 always@(posedge clock)
 begin
      if(!resetn)
     {packet_parity,parity_done}<=0;
      else if(detect_add)//means if it is in decode address state
     {packet_parity,parity_done}<=0;
    else if(rst_int_reg)
     {packet_parity,parity_done}<=0;
       
      else if((ld_state && !fifo_full && !pkt_valid) || (laf_state && !parity_done && low_packet_valid))
     packet_parity<=data_in;
   parity_done<=1;
  end
  endmodule
